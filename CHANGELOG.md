# Changelog



All notable changes to this project will be documented in this file.
## [Unreleased]
## Fixed
- Login after a wrong password failed with `user_not_found` even with the
  correct password: the username field was hidden as soon as a username had
  been tried, so the next attempt was submitted without it. The field is now
  only hidden when Keycloak marks the username as fixed (`usernameHidden`),
  like Keycloak's own template, and keeps the typed username.
- Release upload failed because `gh` ran outside a git checkout.
## [v2610.0.0]
## Breaking
- Themes moved into `themes/`: `themes/dkrz` (general DKRZ theme, parent
  of all others) and `themes/freva` (`parent=dkrz`). The repository root is
  no longer a theme itself, and `freva` only works if `dkrz` sits next to it
  in Keycloak's themes directory.
- Releases now ship the themes as `freva-auth-themes.jar` (for Keycloak's
  `providers/` directory) and `freva-auth-themes.tar.gz` (unpack into
  `themes/`). Both always contain all themes. See README, "Deployment".
  When switching to the JAR, remove old `dkrz`/`freva` folders from
  `themes/`, since Keycloak prefers folders over JARs.
## Added
- `dkrz` theme with the DKRZ logo, branding via `theme.properties`
- Passkey login, links to the account console, account console theme
- Dark mode following the browser/OS setting
- JAR and tar.gz release assets (`scripts/build-jar.sh`), `scripts/link-themes.sh`
  for deployments from a git clone
## [v2605.0.0]
## Added
- Add change-password template
## [v2510.0.0]
## Added
- Add logout template
