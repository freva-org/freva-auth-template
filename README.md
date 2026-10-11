# FREVA Authentication Theme

This repo serves as a custom styled Keycloak FTL-based theme for FREVA.


## Development

### Local test

1. Clone the repository
   ```bash
   git clone https://github.com/FREVA-CLINT/freva-auth-template.git
   cd freva-auth-template
   ```

2. Preview all themes locally using the renderer
   ```bash
   node scripts/render_ftl.js
   ```
   
3. preview in browser
   ```bash
   open preview-build/index.html
   ```


### Themes

Each folder in `themes/` is one Keycloak theme with a `login/` and an
`account/` part:

| Theme   | Purpose                                         |
|---------|-------------------------------------------------|
| `dkrz`  | General DKRZ theme and the base for all others. Holds every template, the stylesheets and the photos. |
| `freva` | Freva branding on top of `dkrz` (`parent=dkrz`). Only properties, logo, favicon and colours. |

Deploy by copying the theme folders into Keycloak's `themes/` directory
(all of them, since children need their parent), then pick one per realm
under **Realm settings → Themes** (login theme and account theme).

#### Adding a theme for another service

1. Create `themes/<name>/login/theme.properties` with `parent=dkrz` and
   override the branding properties: `brandName`, `brandTitle`,
   `brandLogo`, `brandFavicon`, `brandAccent`, `brandAccentHover`,
   `brandAccentSoft`, `brandAccentRing`, `heroTitle`, `heroSubtitle`,
   `supportEmail`, `termsUrl`, `passwordResetUrl`, `registerUrl`.
   Anything you leave out comes from `themes/dkrz/login/theme.properties`.
2. Put the logo and favicon in `themes/<name>/login/resources/img/`.
3. For the account console, create `themes/<name>/account/theme.properties`
   with `parent=dkrz`, `logo`, `favIcon`, `title` and
   `styles=css/account.css css/brand.css`, and a `resources/css/brand.css`
   that sets the `--brand-*` colour variables (see `themes/freva`).

Only copy a template (`*.ftl`) into a child theme if its layout really has
to differ; Keycloak uses the child's file and falls back to `dkrz` for the
rest.

### Passkeys

The login page shows a "Sign in with Passkey" button and a link to set one up
once passkeys are enabled in **Authentication → Policies → WebAuthn
Passwordless Policy** (Keycloak 26.4 or newer). Nothing changes while they
are disabled.

### Making Theme Changes

1. **Modify FTL templates** in the `themes/dkrz/login` directory:
   - `login.ftl` - Login page

2. **Customize branding** in a theme's `theme.properties`

3. **Test your changes** by running the preview script

