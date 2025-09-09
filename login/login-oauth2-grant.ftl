<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="robots" content="noindex, nofollow">
    
    <title>${msg("oauthGrantTitle",(realm.displayName!''))}</title>
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
        
        .grant-container {
            background: white;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            padding: 40px;
            max-width: 500px;
            width: 100%;
            margin: 20px;
        }
        
        h1 {
            font-size: 28px;
            margin-bottom: 10px;
            color: #333;
        }
        
        .subtitle {
            color: #777;
            margin-bottom: 30px;
            font-size: 16px;
        }
        
        .permissions-list {
            margin: 20px 0 30px 0;
        }
        
        .permissions-list ul {
            list-style: none;
            padding: 0;
        }
        
        .permissions-list li {
            padding: 8px 0;
            color: #555;
            border-bottom: 1px solid #eee;
        }
        
        .permissions-list li:last-child {
            border-bottom: none;
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
        .button-group {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }
        
        .submit-button {
            flex: 1;
            background-color: #d14dc3;
            color: white;
            border: none;
            border-radius: 4px;
            padding: 12px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        
        .submit-button:hover {
            background-color: #b23ca4;
        }
        
        .cancel-button {
            flex: 1;
            background-color: #6c757d;
            color: white;
            border: none;
            border-radius: 4px;
            padding: 12px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        
        .cancel-button:hover {
            background-color: #5a6268;
        }

        #kc-error-message {
            background-color: #f8d7da;
            color: #721c24;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        
        @media (max-width: 768px) {
            .grant-container {
                margin: 10px;
                padding: 30px 20px;
            }
            
            .button-group {
                flex-direction: column;
            }
        }
    </style>
</head>

<body>
    <div class="grant-container">
        <div class="logo">
            <img src="${url.resourcesPath}/img/freva.png" alt="Freva" />
        </div>
        
        <h1>Grant Access to ${client.clientId!'client_freva'}</h1>
        <p class="subtitle">Do you grant these access privileges?</p>
        
        <#if message?has_content && (message.type != 'success')>
            <div id="kc-error-message">
                <p>${kcSanitize(message.summary)?no_esc}</p>
            </div>
        </#if>
        
        <#if oauth.clientScopesRequested??>
            <div class="permissions-list">
                <ul>
                    <#list oauth.clientScopesRequested as clientScope>
                        <li>${advancedMsg(clientScope.consentScreenText)}</li>
                    </#list>
                </ul>
            </div>
        <#else>
            <div class="permissions-list">
                <ul>
                    <li>Offline Access</li>
                    <li>User roles</li>
                    <li>openid</li>
                    <li>User profile</li>
                    <li>Email address</li>
                </ul>
            </div>
        </#if>
        
        <form action="${url.oauthAction}" method="POST">
            <div class="button-group">
                <input name="accept" id="kc-accept" type="submit" class="submit-button" value="${msg("doYes")}"/>
                <input name="cancel" id="kc-cancel" type="submit" class="cancel-button" value="${msg("doNo")}"/>
            </div>
        </form>
    </div>
</body>
</html>