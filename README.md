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


### Making Theme Changes

1. **Modify FTL templates** in the `login` directory:
   - `login.ftl` - Login page

2. **Customize styles** in `login/resources/css/styles.css`

3. **Test your changes** by running the preview script

