# Changelog



All notable changes to this project will be documented in this file.
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
