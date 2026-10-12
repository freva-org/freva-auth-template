<#import "passkeys.ftl" as passkeys>
<#-- Realm base URL (incl. any context path such as /auth), derived from the
     form action: https://host[/auth]/realms/<realm> -->
<#assign realmBaseUrl = url.loginAction?keep_before("/login-actions/")>
<#assign accountUrl = realmBaseUrl + "/account">
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="robots" content="noindex, nofollow">
    
    <title>${msg("loginTitle",(realm.displayName!''))}</title>
    <link rel="icon" href="${url.resourcesPath}/${properties.brandFavicon}" />

    <#-- Keycloak's passkey JS imports the bare module "rfc4648"; the stock
         template.ftl maps it with this import map. Without it the module
         fails to load and the passkey button does nothing. Must come before
         any <script type="module">. -->
    <script type="importmap">
        {
            "imports": {
                "rfc4648": "${url.resourcesCommonPath}/vendor/rfc4648/rfc4648.js"
            }
        }
    </script>
    
    <style>
        <#include "brand-vars.ftl">
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
        }
        
        body {
            min-height: 100vh;
            display: flex;
        }
        
        .login-container {
            display: flex;
            width: 100%;
            min-height: 100vh;
        }
        
        .form-container {
            flex: 1;
            padding: 40px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            max-width: 500px;
        }
        
        .image-container {
            flex: 1.2;
            position: relative;
            color: white;
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 40px;
        }
        
        .slide {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-size: cover;
            background-position: center;
            opacity: 0;
            transition: opacity 1s ease-in-out;
            z-index: 0;
        }
        
        .slide.active {
            opacity: 1;
            z-index: 1;
        }
        
        .slide1 { background-image: url("${url.resourcesPath}/img/dkrz1.png"); }
        .slide2 { background-image: url("${url.resourcesPath}/img/dkrz2.png"); }
        .slide3 { background-image: url("${url.resourcesPath}/img/dkrz3.png"); }
        .slide4 { background-image: url("${url.resourcesPath}/img/dkrz4.png"); }
        .slide5 { background-image: url("${url.resourcesPath}/img/dkrz5.png"); }
        
        .overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.4);
            z-index: 2;
        }
        
        .image-content {
            position: relative;
            z-index: 3;
        }
        
        .brand-logo {
            display: block;
            max-width: 210px;
            max-height: 75px;
            margin-bottom: 24px;
        }

        h1 {
            font-size: 32px;
            margin-bottom: 10px;
            color: var(--text);
        }
        
        h2 {
            font-size: 36px;
            font-weight: bold;
            margin-bottom: 20px;
        }
        
        .subtitle {
            color: var(--text-muted);
            margin-bottom: 30px;
        }
        
        .social-buttons {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 30px;
        }
        
        .social-button {
            min-width: 150px;
            padding: 12px;
            border: 1px solid var(--border);
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            background-color: var(--surface);
            transition: background-color 0.3s;
            text-decoration: none;
            color: var(--text);
        }
        
        .social-button:hover {
            background-color: var(--surface-hover);
        }
        
        .social-button img {
            width: 20px;
            margin-right: 10px;
        }
        
        .divider {
            display: flex;
            align-items: center;
            margin: 20px 0;
            color: var(--text-muted);
        }
        
        .divider::before, .divider::after {
            content: "";
            flex: 1;
            border-bottom: 1px solid var(--border);
        }
        
        .divider span {
            padding: 0 10px;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        input {
            width: 100%;
            padding: 12px;
            border: 1px solid var(--border);
            border-radius: 4px;
            font-size: 16px;
        }
        
        .submit-button {
            background-color: var(--brand-accent);
            color: white;
            border: none;
            border-radius: 4px;
            padding: 12px;
            font-size: 16px;
            cursor: pointer;
            margin-top: 15px;
            transition: background-color 0.3s;
        }
        
        .submit-button:hover {
            background-color: var(--brand-accent-hover);
        }
        
        .footer {
            margin-top: 20px;
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            color: var(--text-muted);
        }
        
        .footer a {
            color: var(--text-muted);
            text-decoration: none;
        }
        
        .footer a:hover {
            text-decoration: underline;
        }
        
        .register-link {
            text-align: center;
            margin-top: 15px;
            font-size: 14px;
            color: var(--text-muted);
        }
        
        .register-link a {
            color: var(--brand-accent);
            text-decoration: none;
        }
        
        .register-link a:hover {
            text-decoration: underline;
        }
        
        .pagination {
            position: absolute;
            bottom: 30px;
            right: 30px;
            display: flex;
            align-items: center;
            color: white;
            z-index: 3;
        }
        
        .pagination span {
            margin: 0 5px;
        }
        
        .pagination button {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            border: 1px solid white;
            background: transparent;
            color: white;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .author {
            margin-top: 20px;
            font-size: 16px;
        }
        
        .passkey-login a.passkey-button {
            display: block;
            width: 100%;
            padding: 12px;
            border: 1px solid var(--brand-accent);
            border-radius: 4px;
            background-color: var(--surface);
            color: var(--brand-accent);
            font-size: 16px;
            text-align: center;
            text-decoration: none;
            transition: background-color 0.3s;
        }

        .passkey-login a.passkey-button:hover {
            background-color: var(--brand-accent-soft);
        }

        .passkey-setup-link {
            display: block;
            text-align: center;
            margin-top: 10px;
            font-size: 14px;
            color: var(--text-muted);
            text-decoration: none;
        }

        .passkey-setup-link:hover {
            color: var(--brand-accent);
            text-decoration: underline;
        }

        .remember-me {
            display: flex;
            align-items: center;
            margin-top: 10px;
        }
        
        .remember-me input[type="checkbox"] {
            width: auto;
            margin-right: 10px;
        }
        
        .forgot-password {
            display: block;
            text-align: right;
            margin-top: 10px;
            font-size: 14px;
            color: var(--text-muted);
            text-decoration: none;
        }
        
        .forgot-password:hover {
            text-decoration: underline;
        }
        
        #kc-error-message {
            background-color: var(--error-bg);
            color: var(--error-text);
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 20px;
        }

        .username-with-restart {
            display: flex;
            align-items: center;
            padding: 12px;
            border: 1px solid var(--border);
            border-radius: 4px;
            background-color: var(--page-bg);
            justify-content: space-between;
            font-size: 16px;
        }

        .attempted-username {
            font-weight: 500;
            color: var(--text);
            flex: 1;
        }

        .restart-login-link {
            display: flex;
            align-items: center;
            text-decoration: none;
            color: var(--brand-accent);
            margin-left: 10px;
            font-size: 14px;
        }

        .restart-login-link:hover {
            color: var(--brand-accent-hover);
            text-decoration: underline;
        }

        .restart-icon {
            margin-right: 5px;
        }
        
        @media (max-width: 768px) {
            .login-container {
                flex-direction: column;
            }
            
            .form-container {
                max-width: 100%;
                padding: 20px;
            }
            
            .image-container {
                display: none;
            }
        }
    </style>
</head>

<body>
    <div class="login-container">
        <div class="form-container">
            <#if (properties.loginShowLogo!"false") == "true">
                <picture><#if (properties.brandDarkMode!"true") == "true" && properties.brandLogoDark?has_content><source srcset="${url.resourcesPath}/${properties.brandLogoDark}" media="(prefers-color-scheme: dark)" /></#if><img class="brand-logo" src="${url.resourcesPath}/${properties.brandLogo}" alt="${properties.brandName}" /></picture>
            </#if>
            <h1>${properties.brandTitle}</h1>
            <p class="subtitle">Sign in to your account</p>
            
            <form id="kc-form-login" action="${url.loginAction}" method="post">
                <#if message?has_content && (message.type != 'success')>
                    <div id="kc-error-message">
                        <p>${kcSanitize(message.summary)?no_esc}</p>
                    </div>
                </#if>
                
                <div class="form-group">
                    <#if auth?has_content && auth.attemptedUsername?has_content>
                        <!-- Re-authentication mode: show attempted username with restart option -->
                        <div class="username-with-restart">
                            <span class="attempted-username">${auth.attemptedUsername}</span>
                            <#if url.loginRestartFlowUrl?has_content>
                                <a href="${url.loginRestartFlowUrl}" class="restart-login-link" aria-label="${msg('restartLoginTooltip')}">
                                    <span class="restart-icon">🔄</span>
                                    <span>${msg("restartLoginTooltip", "Restart login")}</span>
                                </a>
                            </#if>
                        </div>
                    <#else>
                        <input tabindex="1" id="username" name="username" value="${(login.username!'')}" type="text" placeholder="Username" autofocus autocomplete="${(enableWebAuthnConditionalUI?has_content)?then('username webauthn', 'off')}" />
                    </#if>
                </div>
                
                <div class="form-group">
                    <input tabindex="2" id="password" name="password" type="password" placeholder="Password" autocomplete="off" />
                </div>
                
                <div class="remember-me">
                    <#if login.rememberMe??>
                        <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox" checked />
                    <#else>
                        <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox" />
                    </#if>
                    <label for="rememberMe">${msg("rememberMe")}</label>
                </div>
                
                <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
                
                <a href="${properties.passwordResetUrl}" class="forgot-password">Forgot password?</a>
                
                <button tabindex="4" class="submit-button" type="submit">Sign In</button>
            </form>

            <#-- Passkey login (Keycloak >= 26.4). Renders nothing unless passkeys
                 are enabled in the WebAuthn Passwordless Policy. Must stay outside
                 kc-form-login because it brings its own forms. -->
            <#if enableWebAuthnConditionalUI?has_content>
                <div class="divider">
                    <span>Or</span>
                </div>
                <div class="passkey-login">
                    <@passkeys.conditionalUIData />
                </div>
                <a class="passkey-setup-link" href="${accountUrl}/account-security/signing-in">No passkey yet? Set one up</a>
            </#if>
            
            <#if social.providers?? && social.providers?size != 0>
                <div class="divider">
                    <span>Or, sign in as a guest</span>
                </div>
                
                <div class="social-buttons">
                    <#list social.providers as provider>
                        <#assign providerAlias = provider.alias?lower_case>
                        <#assign socialIcons = ["google", "github", "linkedin"]>
                        <#assign providerIcon = "default-idp">
                        <#assign foundMatch = false>
                        <#list socialIcons as iconType>
                            <#if !foundMatch && providerAlias?contains(iconType)>
                                <#assign providerIcon = iconType>
                                <#assign foundMatch = true>
                            </#if>
                        </#list>
                        
                        <a href="${provider.loginUrl}" class="social-button">
                            <img src="${url.resourcesPath}/img/${providerIcon}-icon.png" alt="${provider.displayName}">
                            <span>${provider.displayName}</span>
                        </a>
                    </#list>
                </div>
            </#if>
            
            <div class="register-link">
                Don't have an account? <a tabindex="5" href="${properties.registerUrl}">Sign up</a>
            </div>
            
            <div class="footer">
                <a href="mailto:${properties.supportEmail}?subject=Authentication%20Issue">Customer Support</a>
                <a href="${accountUrl}">Manage account</a>
                <a href="${properties.termsUrl}">Terms of Service</a>
            </div>
        </div>
        
        <div class="image-container">
            <div class="slide slide1 active"></div>
            <div class="slide slide2"></div>
            <div class="slide slide3"></div>
            <div class="slide slide4"></div>
            <div class="slide slide5"></div>
            <div class="overlay"></div>
            <div class="image-content">
                <h2>${properties.heroTitle}</h2>
                <p class="author">${properties.heroSubtitle}</p>
            </div>
            <div class="pagination">
                <span id="current-slide">1</span> of <span>5</span>
                <button aria-label="Previous" id="prev-slide"><</button>
                <button aria-label="Next" id="next-slide">></button>
            </div>
        </div>
    </div>
    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const attemptedUsername = document.querySelector('.attempted-username');
            const firstInput = document.getElementById('username');
            
            if (attemptedUsername) {
                // focus on password
                const passwordInput = document.getElementById('password');
                if (passwordInput) passwordInput.focus();
            } else if (firstInput) {
                // focus on username
                firstInput.focus();
            }
            
            // Slideshow functionality
            const slides = document.querySelectorAll('.slide');
            const totalSlides = slides.length;
            let currentSlide = 0;
            const slideCounter = document.getElementById('current-slide');
            const prevButton = document.getElementById('prev-slide');
            const nextButton = document.getElementById('next-slide');
            
            // Auto-advance slides every 5 secs
            let slideInterval = setInterval(nextSlide, 5000);
            
            function showSlide(n) {
                slides.forEach(slide => {
                    slide.classList.remove('active');
                });
                
                // current slide
                slides[n].classList.add('active');
                
                // Update counter
                slideCounter.textContent = n + 1;
            }
            
            function nextSlide() {
                currentSlide = (currentSlide + 1) % totalSlides;
                showSlide(currentSlide);
            }
            
            function prevSlide() {
                currentSlide = (currentSlide - 1 + totalSlides) % totalSlides;
                showSlide(currentSlide);
            }
            
            // pagination buttons
            if (prevButton && nextButton) {
                prevButton.addEventListener('click', function() {
                    clearInterval(slideInterval);
                    prevSlide();
                    slideInterval = setInterval(nextSlide, 5000);
                });
                
                nextButton.addEventListener('click', function() {
                    clearInterval(slideInterval);
                    nextSlide();
                    slideInterval = setInterval(nextSlide, 5000);
                });
            }
        });
    </script>
</body>
</html>
