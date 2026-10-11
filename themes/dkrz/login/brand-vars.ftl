<#-- Brand colours as CSS variables, read from theme.properties.
     Included at the top of every template's <style> block, so a child
     theme only has to set brandAccent* in its theme.properties. -->
        :root {
            --brand-accent: ${properties.brandAccent!'#005092'};
            --brand-accent-hover: ${properties.brandAccentHover!'#003d70'};
            --brand-accent-soft: ${properties.brandAccentSoft!'#e5eef5'};
            --brand-accent-ring: ${properties.brandAccentRing!'rgba(0, 80, 146, 0.2)'};
        }
