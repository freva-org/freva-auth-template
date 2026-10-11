<#-- Brand and colour-scheme variables, read from theme.properties.
     Included at the top of every template's <style> block. Templates only
     use these variables, so a child theme sets brand* properties and gets
     light and dark mode for free. Dark mode follows the browser/OS
     setting (prefers-color-scheme) unless brandDarkMode=false. -->
        :root {
            color-scheme: light<#if (properties.brandDarkMode!"true") == "true"> dark</#if>;

            --brand-accent: ${properties.brandAccent!'#005092'};
            --brand-accent-hover: ${properties.brandAccentHover!'#003d70'};
            --brand-accent-soft: ${properties.brandAccentSoft!'#e5eef5'};
            --brand-accent-ring: ${properties.brandAccentRing!'rgba(0, 80, 146, 0.2)'};

            --page-bg: #f8f9fa;
            --surface: #ffffff;
            --surface-hover: #f5f5f5;
            --input-bg: #ffffff;
            --text: #333333;
            --text-secondary: #555555;
            --text-muted: #777777;
            --border: #dddddd;
            --border-subtle: #eeeeee;
            --error-bg: #f8d7da;
            --error-text: #721c24;
            --error-strong: #d32f2f;
            --info-bg: #e3f2fd;
        }
<#if (properties.brandDarkMode!"true") == "true">
        @media (prefers-color-scheme: dark) {
            :root {
                --brand-accent: ${properties.brandAccentDark!properties.brandAccent!'#3a8ad4'};
                --brand-accent-hover: ${properties.brandAccentDarkHover!properties.brandAccentHover!'#4a96dc'};
                --brand-accent-soft: ${properties.brandAccentDarkSoft!'rgba(255, 255, 255, 0.08)'};
                --brand-accent-ring: ${properties.brandAccentDarkRing!properties.brandAccentRing!'rgba(58, 138, 212, 0.35)'};

                --page-bg: #121417;
                --surface: #1b1d21;
                --surface-hover: #26292e;
                --input-bg: #15171a;
                --text: #e6e6e6;
                --text-secondary: #c2c6ca;
                --text-muted: #9aa0a6;
                --border: #3a3d42;
                --border-subtle: #2c2f33;
                --error-bg: #3d1b1f;
                --error-text: #f5b5bb;
                --error-strong: #ff7b7b;
                --info-bg: #13263a;
            }
        }
</#if>

        body {
            background-color: var(--surface);
            color: var(--text);
        }

        input, select, textarea {
            background-color: var(--input-bg);
            color: var(--text);
        }
