<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="robots" content="noindex, nofollow">
    
    <title>Device Authorization - ${realm.displayName!''}</title>
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
        
        .status-container {
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
        
        .status-message {
            font-size: 18px;
            margin-bottom: 20px;
            color: #333;
        }
        
        .status-description {
            color: #777;
            margin-bottom: 30px;
            line-height: 1.5;
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
            margin: 10px;
            text-decoration: none;
            display: inline-block;
        }
        
        .secondary-button:hover {
            background-color: #5a6268;
            text-decoration: none;
            color: white;
        }
        
        #kc-error-message {
            background-color: #f8d7da;
            color: #721c24;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        
        .info-text {
            background-color: #e3f2fd;
            border-left: 4px solid #2196f3;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        
        @media (max-width: 768px) {
            .status-container {
                margin: 10px;
                padding: 30px 20px;
            }
        }
    </style>
</head>

<body>
    <div class="status-container">
        <div class="logo">
            <img src="${url.resourcesPath}/img/freva.png" alt="Freva" />
        </div>
        
        <#if message?has_content && (message.type != 'success')>
            <div id="kc-error-message">
                <p>${kcSanitize(message.summary)?no_esc}</p>
            </div>
        </#if>
        
        <#if message?has_content && message.type == 'success'>
            <h1>Authorization Complete</h1>
            <p class="status-message">Your device has been successfully authorized</p>
            <div class="info-text">
                <p>${kcSanitize(message.summary)?no_esc}</p>
            </div>
            <p class="status-description">
                You can now return to your device. The application should automatically continue.
            </p>
            <#-- Only show button if not already logged in -->
            <#if !(message.summary?? && message.summary?contains("already logged"))>
                <a href="${url.loginUrl}" class="secondary-button">Return to Login</a>
            </#if>
            
        <#elseif message?has_content && message.type == 'error'>
            <h1>Authorization Failed</h1>
            <p class="status-message">There was an issue with the authorization</p>
            <p class="status-description">
                Please try again or contact support if the problem persists.
            </p>
            <a href="/realms/${realm.name}/device" class="secondary-button">Try Again</a>
            
        <#else>
            <h1>Device Authorization</h1>
            <p class="status-message">Processing authorization...</p>
            <p class="status-description">
                Please complete the verification process on your device or browser.
            </p>
            <a href="/realms/${realm.name}/device" class="secondary-button">Start Over</a>
        </#if>
    </div>
</body>
</html>