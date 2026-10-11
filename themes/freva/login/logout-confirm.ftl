<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="robots" content="noindex, nofollow">
    
    <title>${msg("logoutConfirmTitle")}</title>
    <link rel="icon" href="${url.resourcesPath}/img/favicon.ico" />
    
    <style>
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
            background-color: #f8f9fa;
        }
        
        .logout-container {
            background: white;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            padding: 40px;
            max-width: 500px;
            width: 100%;
            margin: 20px;
            text-align: center;
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
        
        h1 {
            font-size: 28px;
            margin-bottom: 20px;
            color: #333;
        }
        
        .logout-message {
            font-size: 18px;
            margin-bottom: 30px;
            color: #555;
            line-height: 1.5;
        }
        
        .button-group {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }
        
        .submit-button {
            background-color: #d14dc3;
            color: white;
            border: none;
            border-radius: 4px;
            padding: 12px 24px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        
        .submit-button:hover {
            background-color: #b23ca4;
        }
        
        .secondary-button {
            background-color: #6c757d;
            color: white;
            border: none;
            border-radius: 4px;
            padding: 12px 24px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s;
            text-decoration: none;
            display: inline-block;
        }
        
        .secondary-button:hover {
            background-color: #5a6268;
            text-decoration: none;
            color: white;
        }
        
        .footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            font-size: 14px;
            color: #777;
        }
        
        .footer a {
            color: #777;
            text-decoration: none;
        }
        
        .footer a:hover {
            text-decoration: underline;
        }
        
        @media (max-width: 768px) {
            .logout-container {
                margin: 10px;
                padding: 30px 20px;
            }
            
            .button-group {
                flex-direction: column;
            }
            
            .submit-button,
            .secondary-button {
                width: 100%;
            }
        }
    </style>
</head>

<body>
    <div class="logout-container">
        <div class="logo">
            <img src="${url.resourcesPath}/img/freva.png" alt="Freva" />
        </div>
        
        <h1>${msg("logoutConfirmTitle")}</h1>
        <p class="logout-message">${msg("logoutConfirmHeader")}</p>
        
        <form action="${url.logoutConfirmAction}" method="POST" onsubmit="confirmLogout.disabled = true; return true;">
            <input type="hidden" name="session_code" value="${logoutConfirm.code}">
            
            <div class="button-group">
                <button class="submit-button" name="confirmLogout" id="kc-logout" type="submit">
                    ${msg("doLogout")}
                </button>
                
                <#if (client.baseUrl)?has_content && !logoutConfirm.skipLink>
                    <a href="${client.baseUrl}" class="secondary-button">
                        ${kcSanitize(msg("backToApplication"))?no_esc}
                    </a>
                </#if>
            </div>
        </form>
        
        <div class="footer">
            <a href="mailto:freva@dkrz.de?subject=Authentication Issue">Customer Support</a>
            <span style="margin: 0 10px;">|</span>
            <a href="https://docs.dkrz.de/doc/getting_started/benutzungsrichtlinien.html">Terms of Service</a>
        </div>
    </div>
</body>
</html>
