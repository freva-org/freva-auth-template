# FREVA Authentication Theme

This repo serves as a custom styled Keycloak FTL-based theme for FREVA.


## Development

### Local test

1. Clone the repository
   ```bash
   git clone https://github.com/FREVA-CLINT/freva-auth-template.git
   cd freva-auth-template
   ```

2. Preview theme locally using the renderer
   ```bash
   node scripts/render-ftl.js
   ```
   
3. preview in browser
   ```bash
   open preview-build/index.html
   ```


### Theme types

The repository ships two Keycloak theme types. Copy the repository into
Keycloak's `themes/<name>/` directory and select them per realm under
**Realm settings → Themes**:

- `login/`: the login pages (login theme).
- `account/`: the account console (account theme). It extends Keycloak's
  `keycloak.v3` account console and only changes colours, header and logo,
  so it keeps working across Keycloak upgrades.

### Passkeys

The login page shows a "Sign in with Passkey" button and a link to set one up
once passkeys are enabled in **Authentication → Policies → WebAuthn
Passwordless Policy** (Keycloak 26.4 or newer). Nothing changes while they
are disabled.

### Making Theme Changes

1. **Modify FTL templates** in the `login` directory:
   - `login.ftl` - Login page

2. **Customize styles** in `login/resources/css/styles.css`

3. **Test your changes** by running the preview script

