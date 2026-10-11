<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="robots" content="noindex, nofollow">
    
    <title>${msg("updateProfileTitle",(realm.displayName!''))}</title>
    <link rel="icon" href="${url.resourcesPath}/${properties.brandFavicon}" />
    
    <style>
        <#include "brand-vars.ftl">
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
        }
        
        body {
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: var(--page-bg);
        }
        
        .profile-container {
            background: var(--surface);
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            padding: 40px;
            max-width: 500px;
            width: 100%;
            margin: 20px;
        }
        .logo {
            display: flex;
            justify-content: center;
            align-items: center;
            margin-bottom: 30px;
            width: 100%;
        }
        
        .logo img {
            max-height: 60px;
            width: auto;
        }
        .required-fields {
            color: var(--text-muted);
            font-size: 14px;
            margin-bottom: 20px;
        }
        
        h1 {
            font-size: 28px;
            margin-bottom: 30px;
            color: var(--text);
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        label {
            display: block;
            margin-bottom: 5px;
            color: var(--text);
            font-weight: 500;
        }
        
        .required {
            color: var(--brand-accent);
        }
        
        input[type="text"], input[type="email"] {
            width: 100%;
            padding: 12px;
            border: 1px solid var(--border);
            border-radius: 4px;
            font-size: 16px;
        }
        
        input[type="text"]:focus, input[type="email"]:focus {
            outline: none;
            border-color: var(--brand-accent);
            box-shadow: 0 0 0 2px var(--brand-accent-ring);
        }
        
        .submit-button {
            width: 100%;
            background-color: var(--brand-accent);
            color: white;
            border: none;
            border-radius: 4px;
            padding: 12px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s;
            margin-top: 10px;
        }
        
        .submit-button:hover {
            background-color: var(--brand-accent-hover);
        }

        #kc-error-message {
            background-color: var(--error-bg);
            color: var(--error-text);
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 20px;
        }

        .field-error {
            color: var(--error-strong);
            font-size: 14px;
            margin-top: 5px;
        }
        
        @media (max-width: 768px) {
            .profile-container {
                margin: 10px;
                padding: 30px 20px;
            }
        }
    </style>
</head>

<body>
    <div class="profile-container">
        <div class="logo">
            <picture><#if (properties.brandDarkMode!"true") == "true" && properties.brandLogoDark?has_content><source srcset="${url.resourcesPath}/${properties.brandLogoDark}" media="(prefers-color-scheme: dark)" /></#if><img src="${url.resourcesPath}/${properties.brandLogo}" alt="${properties.brandName}" /></picture>
        </div>
        
        <p class="required-fields">* Required fields</p>
        
        <h1>Update Account Information</h1>
        
        <#if message?has_content && (message.type != 'success')>
            <div id="kc-error-message">
                <p>${kcSanitize(message.summary)?no_esc}</p>
            </div>
        </#if>
        
        <form id="kc-update-profile-form" action="${url.loginAction}" method="post">
            <div class="form-group">
                <label for="email">
                    ${msg("email")} <span class="required">*</span>
                </label>
                <input type="email" id="email" name="email" 
                       value="${(user.email!'')}" 
                       autocomplete="email" 
                       <#if realm.registrationEmailAsUsername>autofocus</#if> 
                       <#if !realm.editUsernameAllowed>readonly</#if> />
                <#if messagesPerField.existsError('email')>
                    <div class="field-error">
                        ${kcSanitize(messagesPerField.get('email'))?no_esc}
                    </div>
                </#if>
            </div>

            <div class="form-group">
                <label for="firstName">
                    ${msg("firstName")} <span class="required">*</span>
                </label>
                <input type="text" id="firstName" name="firstName" 
                       value="${(user.firstName!'')}" 
                       autocomplete="given-name"
                       <#if !realm.registrationEmailAsUsername>autofocus</#if> />
                <#if messagesPerField.existsError('firstName')>
                    <div class="field-error">
                        ${kcSanitize(messagesPerField.get('firstName'))?no_esc}
                    </div>
                </#if>
            </div>

            <div class="form-group">
                <label for="lastName">
                    ${msg("lastName")} <span class="required">*</span>
                </label>
                <input type="text" id="lastName" name="lastName" 
                       value="${(user.lastName!'')}" 
                       autocomplete="family-name" />
                <#if messagesPerField.existsError('lastName')>
                    <div class="field-error">
                        ${kcSanitize(messagesPerField.get('lastName'))?no_esc}
                    </div>
                </#if>
            </div>

            <#if user.editUsernameAllowed && !realm.registrationEmailAsUsername>
                <div class="form-group">
                    <label for="username">
                        ${msg("username")} <span class="required">*</span>
                    </label>
                    <input type="text" id="username" name="username" 
                           value="${(user.username!'')}" 
                           autocomplete="username" />
                    <#if messagesPerField.existsError('username')>
                        <div class="field-error">
                            ${kcSanitize(messagesPerField.get('username'))?no_esc}
                        </div>
                    </#if>
                </div>
            </#if>

            <button type="submit" class="submit-button">
                ${msg("doSubmit")}
            </button>
        </form>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const firstInput = document.querySelector('input[type="text"], input[type="email"]');
            if (firstInput && firstInput.hasAttribute('autofocus')) {
                firstInput.focus();
            }
        });
    </script>
</body>
</html>