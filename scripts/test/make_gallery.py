"""Build a static gallery page from the screenshots of check_themes.py.

    python scripts/test/make_gallery.py SCREENSHOT_DIR OUTPUT_DIR

Screenshots are named <theme>-<scheme>-<page>.png. The page shows every
theme with its login, account and logout pages, switchable between light
and dark, with a click-to-enlarge view. Images are converted to WebP
(full size and thumbnail) to keep the Pages site small.

Optional environment: KC_VERSION, GITHUB_SHA, GITHUB_REPOSITORY,
GITHUB_SERVER_URL, GITHUB_RUN_ID (shown in the footer).
"""

import html
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

from PIL import Image

REPO = Path(__file__).resolve().parents[2]
PAGES = [("login", "Login"), ("account", "Account console"), ("logout", "Logout")]
SCHEMES = ("light", "dark")
NAME = re.compile(r"^(?P<theme>.+)-(?P<scheme>light|dark)-(?P<page>login|account|logout)\.png$")


def read_properties(path: Path) -> dict:
    props = {}
    if path.is_file():
        for line in path.read_text().splitlines():
            m = re.match(r"\s*([^#!\s][^=]*?)\s*=\s*(.*)$", line)
            if m:
                props[m.group(1)] = m.group(2).strip()
    return props


def theme_info(theme: str) -> dict:
    """Merged login theme.properties of a theme and its parents."""
    chain, name = [], theme
    while name and (REPO / "themes" / name / "login").is_dir():
        props = read_properties(REPO / "themes" / name / "login" / "theme.properties")
        chain.append((name, props))
        name = props.get("parent")
    merged = {}
    for _, props in reversed(chain):
        merged.update(props)
    parent = chain[0][1].get("parent") if chain else None
    merged["_parent"] = parent if parent and parent != "base" else ""
    return merged


def convert(src: Path, out: Path, stem: str) -> None:
    img = Image.open(src).convert("RGB")
    img.save(out / f"{stem}.webp", "WEBP", quality=85, method=6)
    thumb = img.copy()
    thumb.thumbnail((700, 700))
    thumb.save(out / f"{stem}-thumb.webp", "WEBP", quality=80, method=6)


def esc(value) -> str:
    return html.escape(str(value), quote=True)


def color(value: str, fallback: str) -> str:
    """Only pass through plain CSS colour values from theme.properties."""
    return value if re.fullmatch(r"#[0-9a-fA-F]{3,8}|rgba?\([0-9.,\s%]+\)", value or "") else fallback


def build(shots: Path, out: Path) -> int:
    found = {}
    for f in sorted(shots.glob("*.png")):
        m = NAME.match(f.name)
        if m:
            found.setdefault(m["theme"], {})[(m["scheme"], m["page"])] = f
    if not found:
        print(f"no screenshots in {shots}", file=sys.stderr)
        return 1

    img_dir = out / "img"
    img_dir.mkdir(parents=True, exist_ok=True)

    sections, nav = [], []
    for theme in sorted(found):
        info = theme_info(theme)
        accent = color(info.get("brandAccent", ""), "#005092")
        accent_dark = color(info.get("brandAccentDark", ""), accent)
        title = info.get("brandTitle") or theme
        parent = f'<span class="tag">parent: {esc(info["_parent"])}</span>' if info["_parent"] else ""
        cards = []
        for page, label in PAGES:
            figs = []
            for scheme in SCHEMES:
                src = found[theme].get((scheme, page))
                if not src:
                    continue
                stem = f"{theme}-{scheme}-{page}"
                convert(src, img_dir, stem)
                alt = f"{title}, {label.lower()} page, {scheme} mode"
                figs.append(
                    f'<a class="shot" data-scheme="{scheme}" href="img/{stem}.webp" '
                    f'data-caption="{esc(theme)} · {esc(label)} · {scheme}">'
                    f'<img src="img/{stem}-thumb.webp" alt="{esc(alt)}" '
                    f'width="700" height="425" loading="lazy"></a>'
                )
            if figs:
                cards.append(
                    f'<figure class="card">{"".join(figs)}'
                    f"<figcaption>{esc(label)}</figcaption></figure>"
                )
        nav.append(f'<a href="#{esc(theme)}">{esc(theme)}</a>')
        sections.append(f"""
<section id="{esc(theme)}" style="--accent:{accent};--accent-dark:{accent_dark}">
  <header class="theme-head">
    <span class="swatch" aria-hidden="true"></span>
    <h2>{esc(theme)}</h2>
    <span class="subtitle">{esc(title)}</span>
    {parent}
  </header>
  <div class="grid">{"".join(cards)}</div>
</section>""")

    kc = os.environ.get("KC_VERSION", "").strip()
    sha = os.environ.get("GITHUB_SHA", "")[:7]
    repo = os.environ.get("GITHUB_REPOSITORY", "")
    server = os.environ.get("GITHUB_SERVER_URL", "https://github.com")
    run = os.environ.get("GITHUB_RUN_ID", "")
    meta = [f"Rendered by Keycloak {esc(kc)}" if kc else "Rendered by Keycloak"]
    if sha and repo:
        meta.append(f'commit <a href="{esc(server)}/{esc(repo)}/commit/{esc(sha)}">{esc(sha)}</a>')
    if run and repo:
        meta.append(f'<a href="{esc(server)}/{esc(repo)}/actions/runs/{esc(run)}">test run</a>')
    meta.append(datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC"))
    preview = ' · <a href="preview/">static template preview</a>' if (out / "preview").is_dir() else ""

    (out / "index.html").write_text(PAGE.format(
        nav=" ".join(nav), sections="".join(sections),
        meta=" · ".join(meta), preview=preview,
    ))
    print(f"gallery: {out / 'index.html'} ({len(found)} themes)")
    return 0


PAGE = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Keycloak Theme Gallery</title>
<style>
  :root {{
    --bg: #f6f7f9; --surface: #fff; --text: #1d2125; --muted: #5f6b76;
    --border: #e1e5ea; --chip: #eef1f4; --chip-on: #1d2125; --chip-on-text: #fff;
  }}
  @media (prefers-color-scheme: dark) {{
    :root {{
      --bg: #111316; --surface: #1a1d21; --text: #e7e9ec; --muted: #9aa3ad;
      --border: #2c3036; --chip: #23272c; --chip-on: #e7e9ec; --chip-on-text: #111316;
    }}
  }}
  * {{ box-sizing: border-box; }}
  body {{
    margin: 0; background: var(--bg); color: var(--text);
    font: 15px/1.5 system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
  }}
  a {{ color: inherit; }}
  .top {{
    position: sticky; top: 0; z-index: 5; background: var(--bg);
    border-bottom: 1px solid var(--border);
  }}
  .bar {{
    max-width: 1200px; margin: 0 auto; padding: 14px 16px;
    display: flex; flex-wrap: wrap; gap: 12px 20px; align-items: center;
  }}
  h1 {{ font-size: 18px; margin: 0; letter-spacing: -0.01em; }}
  .themes {{ display: flex; gap: 14px; color: var(--muted); }}
  .themes a {{ text-decoration: none; }}
  .themes a:hover {{ color: var(--text); text-decoration: underline; }}
  .toggle {{
    margin-left: auto; display: inline-flex; background: var(--chip);
    border-radius: 999px; padding: 3px;
  }}
  .toggle button {{
    border: 0; background: transparent; color: var(--muted); font: inherit;
    padding: 4px 14px; border-radius: 999px; cursor: pointer;
  }}
  .toggle button[aria-pressed="true"] {{ background: var(--chip-on); color: var(--chip-on-text); }}
  main {{ max-width: 1200px; margin: 0 auto; padding: 8px 16px 40px; }}
  section {{ padding-top: 28px; scroll-margin-top: 70px; }}
  .theme-head {{ display: flex; align-items: baseline; gap: 10px; flex-wrap: wrap; margin-bottom: 14px; }}
  .theme-head h2 {{ margin: 0; font-size: 22px; }}
  .subtitle {{ color: var(--muted); }}
  .tag {{
    font-size: 12px; color: var(--muted); border: 1px solid var(--border);
    border-radius: 999px; padding: 1px 8px;
  }}
  .swatch {{
    width: 14px; height: 14px; border-radius: 4px; align-self: center;
    background: linear-gradient(135deg, var(--accent) 50%, var(--accent-dark) 50%);
  }}
  .grid {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(330px, 1fr)); gap: 18px; }}
  .card {{
    margin: 0; background: var(--surface); border: 1px solid var(--border);
    border-radius: 10px; overflow: hidden;
  }}
  .card figcaption {{ padding: 9px 12px; color: var(--muted); font-size: 14px; border-top: 1px solid var(--border); }}
  .shot {{ display: block; line-height: 0; }}
  .shot img {{ width: 100%; height: auto; display: block; transition: opacity .15s; }}
  .shot:hover img {{ opacity: .88; }}
  body[data-scheme="light"] .shot[data-scheme="dark"],
  body[data-scheme="dark"] .shot[data-scheme="light"] {{ display: none; }}
  body[data-scheme="both"] .card .shot + .shot {{ border-top: 1px solid var(--border); }}
  footer {{ max-width: 1200px; margin: 0 auto; padding: 0 16px 32px; color: var(--muted); font-size: 13px; }}
  dialog {{
    border: 0; padding: 0; background: transparent; max-width: 96vw; max-height: 94vh;
  }}
  dialog::backdrop {{ background: rgba(0, 0, 0, .8); }}
  dialog img {{ display: block; max-width: 96vw; max-height: 88vh; border-radius: 6px; }}
  dialog p {{ color: #fff; text-align: center; margin: 10px 0 0; font-size: 14px; }}
  @media (max-width: 560px) {{
    .grid {{ grid-template-columns: 1fr; }}
    .toggle {{ margin-left: 0; }}
  }}
</style>
</head>
<body data-scheme="light">
<div class="top">
  <div class="bar">
    <h1>Keycloak Theme Gallery</h1>
    <nav class="themes" aria-label="Themes">{nav}</nav>
    <div class="toggle" role="group" aria-label="Colour scheme">
      <button type="button" data-set="light" aria-pressed="true">Light</button>
      <button type="button" data-set="dark" aria-pressed="false">Dark</button>
      <button type="button" data-set="both" aria-pressed="false">Both</button>
    </div>
  </div>
</div>
<main>{sections}</main>
<footer>{meta}{preview}</footer>
<dialog id="viewer"><img alt=""><p></p></dialog>
<script>
  const body = document.body;
  const buttons = document.querySelectorAll(".toggle button");
  function setScheme(s) {{
    body.dataset.scheme = s;
    buttons.forEach(b => b.setAttribute("aria-pressed", String(b.dataset.set === s)));
    try {{ localStorage.setItem("gallery-scheme", s); }} catch (e) {{}}
  }}
  buttons.forEach(b => b.addEventListener("click", () => setScheme(b.dataset.set)));
  let saved = null;
  try {{ saved = localStorage.getItem("gallery-scheme"); }} catch (e) {{}}
  setScheme(saved || (matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"));

  const viewer = document.getElementById("viewer");
  document.querySelectorAll(".shot").forEach(a => a.addEventListener("click", e => {{
    e.preventDefault();
    viewer.querySelector("img").src = a.href;
    viewer.querySelector("img").alt = a.querySelector("img").alt;
    viewer.querySelector("p").textContent = a.dataset.caption;
    viewer.showModal();
  }}));
  viewer.addEventListener("click", () => viewer.close());
</script>
</body>
</html>
"""


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(__doc__, file=sys.stderr)
        sys.exit(2)
    sys.exit(build(Path(sys.argv[1]), Path(sys.argv[2])))
