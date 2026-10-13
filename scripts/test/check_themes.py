"""Check that every theme in themes/ loads and renders in a real Keycloak.

Expects the realms from setup-realms.sh (one "test-<theme>" realm per
theme, user test/test). For each theme, in light and dark mode:

- the login page is served from that theme (not a fallback),
- the page title is the theme's brandTitle,
- the passkey button and the account/passkey links are present,
- the account console loads with the theme's styles,
- the logout page renders,
- no JavaScript errors occur.

Screenshots go to SCREENSHOT_DIR (default: test-screenshots/).

    KC_URL=http://localhost:8080 python scripts/test/check_themes.py
"""

import os
import re
import sys
from pathlib import Path

from playwright.sync_api import Page, sync_playwright

REPO = Path(__file__).resolve().parents[2]
KC_URL = os.environ.get("KC_URL", "http://localhost:8080").rstrip("/")
SHOTS = Path(os.environ.get("SCREENSHOT_DIR", "test-screenshots"))

# Warnings Keycloak's own pages produce in a headless browser; not ours.
IGNORED_CONSOLE = (
    "allow-scripts and allow-same-origin",
    "Failed to load resource",  # e.g. favicon probes of the account SPA
)


def read_properties(path: Path) -> dict:
    props = {}
    if path.is_file():
        for line in path.read_text().splitlines():
            m = re.match(r"\s*([^#!\s][^=]*?)\s*=\s*(.*)$", line)
            if m:
                props[m.group(1)] = m.group(2).strip()
    return props


def theme_properties(theme: str, kind: str) -> dict:
    """theme.properties of a theme, merged with its parents from themes/."""
    chain, name = [], theme
    while name and (REPO / "themes" / name / kind).is_dir():
        props = read_properties(REPO / "themes" / name / kind / "theme.properties")
        chain.append(props)
        name = props.get("parent")
    merged = {}
    for props in reversed(chain):
        merged.update(props)
    return merged


class Failures(list):
    def check(self, ok: bool, msg: str) -> None:
        print(("  ok    " if ok else "  FAIL  ") + msg)
        if not ok:
            self.append(msg)


def theme_paths(page: Page, kind: str) -> set:
    """Theme names in the resource URLs the page loaded, e.g. /login/freva/."""
    urls = page.eval_on_selector_all(
        "link[href], script[src], img[src], source[srcset]",
        "els => els.map(e => e.href || e.src || e.srcset || '')",
    )
    return {m for u in urls for m in re.findall(rf"/{kind}/([a-z0-9._-]+)/", u)}


def check_theme(browser, theme: str, scheme: str, fails: Failures) -> None:
    realm = f"test-{theme}"
    login_props = theme_properties(theme, "login")
    errors = []
    context = browser.new_context(
        viewport={"width": 1400, "height": 850}, color_scheme=scheme
    )
    page = context.new_page()
    page.on("pageerror", lambda e: errors.append(f"pageerror: {e}"))
    page.on(
        "console",
        lambda m: errors.append(f"console: {m.text}")
        if m.type == "error" and not any(s in m.text for s in IGNORED_CONSOLE)
        else None,
    )
    tag = f"[{theme}/{scheme}]"

    # Login page
    page.goto(f"{KC_URL}/realms/{realm}/account/")
    try:
        page.wait_for_selector("#kc-form-login", timeout=30_000)
    except Exception:
        page.screenshot(path=SHOTS / f"{theme}-{scheme}-login-FAILED.png")
        context.close()
        raise
    page.wait_for_timeout(1000)
    page.screenshot(path=SHOTS / f"{theme}-{scheme}-login.png")
    if login_props:
        fails.check(
            theme in theme_paths(page, "login"),
            f"{tag} login page served from theme '{theme}'",
        )
        expected = login_props.get("brandTitle")
        if expected:
            title = page.inner_text("h1").strip()
            fails.check(title == expected, f"{tag} title '{title}' == '{expected}'")
        fails.check(
            page.locator("#authenticateWebAuthnButton").count() == 1,
            f"{tag} passkey button present",
        )
        fails.check(
            page.locator("a[href*='/account/account-security/signing-in']").count() == 1,
            f"{tag} passkey setup link present",
        )

    # Account console
    page.fill("#username", "test")
    page.fill("#password", "test")
    page.click("button[type=submit], input[type=submit]")
    page.wait_for_load_state("networkidle")
    page.wait_for_selector(".pf-v5-c-page__sidebar, .pf-v5-c-masthead", timeout=30_000)
    page.wait_for_timeout(1500)
    page.screenshot(path=SHOTS / f"{theme}-{scheme}-account.png")
    if (REPO / "themes" / theme / "account").is_dir():
        fails.check(
            theme in theme_paths(page, "account"),
            f"{tag} account console served from theme '{theme}'",
        )
        dark = "pf-v5-theme-dark" in (page.get_attribute("html", "class") or "")
        fails.check(dark == (scheme == "dark"), f"{tag} account dark mode = {dark}")

    # Logout page
    page.goto(f"{KC_URL}/realms/{realm}/protocol/openid-connect/logout")
    page.wait_for_load_state("networkidle")
    page.screenshot(path=SHOTS / f"{theme}-{scheme}-logout.png")
    if login_props:
        fails.check(
            theme in theme_paths(page, "login"),
            f"{tag} logout page served from theme '{theme}'",
        )

    fails.check(not errors, f"{tag} no JavaScript errors" + (f": {errors}" if errors else ""))
    context.close()


def main() -> int:
    SHOTS.mkdir(parents=True, exist_ok=True)
    themes = sorted(p.name for p in (REPO / "themes").iterdir() if p.is_dir())
    fails = Failures()
    with sync_playwright() as p:
        browser = p.chromium.launch()
        for theme in themes:
            for scheme in ("light", "dark"):
                print(f"{theme} ({scheme})")
                try:
                    check_theme(browser, theme, scheme, fails)
                except Exception as exc:  # broken page: report, keep going
                    fails.check(False, f"[{theme}/{scheme}] page did not load: "
                                f"{type(exc).__name__}: {str(exc).splitlines()[0]}")
        browser.close()
    print(f"\n{len(fails)} failure(s), screenshots in {SHOTS}/")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
