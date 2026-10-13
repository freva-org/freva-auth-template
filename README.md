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

### Deployment

Every [release](https://github.com/freva-org/freva-auth-template/releases)
comes with the themes in two formats. Both contain **all** themes, so a
child theme (e.g. `freva`) always comes with its parent (`dkrz`). Pick
one of the options below; the paths assume a standard installation in
`/opt/keycloak`.

| File | Goes into | Good for |
|------|-----------|----------|
| `freva-auth-themes.jar` | `providers/` | Production: one file, nothing to unpack |
| `freva-auth-themes.tar.gz` | `themes/` | If you prefer plain folders you can look into |

Each release also has versioned copies (`freva-auth-themes-<version>.jar`,
`.tar.gz`) and a `SHA256SUMS` file.

#### Option A: JAR in `providers/`

```bash
cd /opt/keycloak
curl -L -o providers/freva-auth-themes.jar \
  https://github.com/freva-org/freva-auth-template/releases/latest/download/freva-auth-themes.jar
bin/kc.sh build        # only needed if you start Keycloak with --optimized
# restart Keycloak
```

To update, replace the JAR with the one from a newer release and restart.
To pin a version, use the versioned file, e.g.
`.../releases/download/v2610.0.0/freva-auth-themes-2610.0.0.jar`.

Remove any `dkrz`/`freva` folders from `themes/` when you switch to the
JAR. Keycloak prefers theme folders over theme JARs, so an old folder would
silently win.

#### Option B: folders in `themes/`

```bash
cd /opt/keycloak
curl -L https://github.com/freva-org/freva-auth-template/releases/latest/download/freva-auth-themes.tar.gz \
  | tar xz -C themes
# restart Keycloak
```

This creates `themes/dkrz` and `themes/freva`. To update, unpack a newer
release over them and restart. No `kc.sh build` is needed for folders.

#### Option C: from a git clone (theme development)

```bash
cd /opt/keycloak/themes
git clone https://github.com/freva-org/freva-auth-template
freva-auth-template/scripts/link-themes.sh
```

`link-themes.sh` links every theme from the clone into the themes
directory, so `git checkout <tag>` plus a restart updates them. Run it
again when a new theme is added to the repository.

#### Docker / Podman

Mount the file or directory into the container, e.g. in compose:

```yaml
volumes:
  - ./freva-auth-themes.jar:/opt/keycloak/providers/freva-auth-themes.jar:ro
  # or, for option B:
  # - ./themes:/opt/keycloak/themes:ro
```

The official image runs `kc.sh start` without `--optimized` unless you
built your own image, so a container restart picks up a new JAR.

#### Activating the themes

After the restart, pick a theme per realm under **Realm settings → Themes**
(*Login theme* and *Account theme*). Clients can override the login theme
under **Clients → (client) → Login settings → Login theme**. If a client
still shows an old theme, check there.

#### Building the files yourself

```bash
scripts/build-jar.sh                                    # dist/freva-auth-themes-<version>.jar
tar czf freva-auth-themes.tar.gz -C themes .            # folders
```

### Adding a theme for another service

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

