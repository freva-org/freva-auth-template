<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="robots" content="noindex, nofollow">
    
    <title>${msg("deviceLoginTitle",(realm.displayName!''))}</title>
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
        
        .device-container {
            background: white;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            padding: 40px;
            max-width: 450px;
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
        
        .form-group {
            margin-bottom: 20px;
        }
        
        input[type="text"] {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
            text-align: center;
            letter-spacing: 2px;
            font-family: monospace;
        }
        
        input[type="text"]:focus {
            outline: none;
            border-color: #d14dc3;
            box-shadow: 0 0 0 2px rgba(209, 77, 195, 0.2);
        }
        
        .submit-button {
            width: 100%;
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
            .device-container {
                margin: 10px;
                padding: 30px 20px;
            }
        }
    </style>
</head>

<body>
    <div class="device-container">
        <div class="logo">
            <img src="${url.resourcesPath}/img/freva.png" alt="Freva" />
        </div>
        
        <h1>Device Login</h1>
        <p class="subtitle">Enter the code provided by your device and click Submit</p>
        
        <#if message?has_content && (message.type != 'success')>
            <div id="kc-error-message">
                <p>${kcSanitize(message.summary)?no_esc}</p>
            </div>
        </#if>

        <#if verificationComplete??>
            <div class="info-text">
                <p>${msg("deviceVerificationComplete")}</p>
            </div>
        <#else>
            <!-- Match exactly what the working version does -->
            <form id="kc-user-verify-device-user-code-form" action="/realms/${realm.name}/device" method="post">
                <div class="form-group">
                    <input id="device-user-code" name="device_user_code" autocomplete="off" type="text" placeholder="XXXX-XXXX" autofocus maxlength="9" />
                </div>
                
                <button type="submit" class="submit-button">
                    ${msg("doSubmit")}
                </button>
            </form>
        </#if>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const input = document.getElementById('device-user-code');

            if (input) {
                if (input.value) {
                    input.value = formatForDisplay(input.value);
                }

                input.addEventListener('input', function(e) {
                    let raw = e.target.value.replace(/[^0-9A-Za-z]/g, '').toUpperCase();

                    if (raw.length > 8) raw = raw.substring(0, 8);

                    e.target.value = formatForDisplay(raw);
                });

                input.form.addEventListener('submit', function(e) {
                    const cleanValue = input.value.replace(/[^0-9A-Za-z]/g, '').toUpperCase();
                    
                    if (cleanValue.length === 0) {
                        e.preventDefault();
                        alert('Please enter a device code');
                        return false;
                    }
                    
                    input.value = cleanValue;
                });

                function formatForDisplay(alnum) {
                    if (!alnum) return '';
                    if (alnum.length <= 4) return alnum;
                    return alnum.substring(0, 4) + '-' + alnum.substring(4);
                }
            }
        });
    </script>
</body>
</html>