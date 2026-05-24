<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="robots" content="noindex, nofollow">

    <title>${msg("updatePasswordTitle")}</title>
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
            overflow: hidden;
            display: flex;
        }

        .login-container {
            display: flex;
            width: 100%;
            height: 100%;
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
            top: 0; left: 0;
            width: 100%; height: 100%;
            background-size: cover;
            background-position: center;
            opacity: 0;
            transition: opacity 1s ease-in-out;
            z-index: 0;
        }

        .slide.active { opacity: 1; z-index: 1; }
        .slide1 { background-image: url("${url.resourcesPath}/img/dkrz1.png"); }
        .slide2 { background-image: url("${url.resourcesPath}/img/dkrz2.png"); }
        .slide3 { background-image: url("${url.resourcesPath}/img/dkrz3.png"); }
        .slide4 { background-image: url("${url.resourcesPath}/img/dkrz4.png"); }
        .slide5 { background-image: url("${url.resourcesPath}/img/dkrz5.png"); }

        .overlay {
            position: absolute;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background-color: rgba(0, 0, 0, 0.4);
            z-index: 2;
        }

        .image-content { position: relative; z-index: 3; }

        h1 { font-size: 32px; margin-bottom: 10px; color: #333; }

        .subtitle { color: #777; margin-bottom: 30px; font-size: 14px; }

        .form-group { margin-bottom: 15px; }

        label { display: block; font-size: 14px; color: #555; margin-bottom: 6px; }

        input[type="password"] {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
        }

        input[type="password"]:focus {
            outline: none;
            border-color: #d14dc3;
        }

        .checkbox-row {
            display: flex;
            align-items: center;
            margin: 10px 0 20px;
            font-size: 14px;
            color: #555;
        }

        .checkbox-row input[type="checkbox"] {
            width: auto;
            margin-right: 10px;
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

        .submit-button:hover { background-color: #b23ca4; }

        #kc-error-message {
            background-color: #f8d7da;
            color: #721c24;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        .pagination {
            position: absolute;
            bottom: 30px; right: 30px;
            display: flex;
            align-items: center;
            color: white;
            z-index: 3;
        }

        .pagination span { margin: 0 5px; }

        .pagination button {
            width: 30px; height: 30px;
            border-radius: 50%;
            border: 1px solid white;
            background: transparent;
            color: white;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        h2 { font-size: 36px; font-weight: bold; margin-bottom: 20px; }
        .author { margin-top: 20px; font-size: 16px; }

        @media (max-width: 768px) {
            .login-container { flex-direction: column; }
            .form-container { max-width: 100%; padding: 20px; }
            .image-container { display: none; }
        }
    </style>
</head>

<body>
    <div class="login-container">
        <div class="form-container">
            <h1>${msg("updatePasswordTitle")}</h1>
            <p class="subtitle">${msg("updatePasswordMessage","You need to change your password to activate your account.")}</p>

            <#if message?has_content && (message.type != 'success')>
                <div id="kc-error-message">
                    <p>${kcSanitize(message.summary)?no_esc}</p>
                </div>
            </#if>

            <form id="kc-passwd-update-form" action="${url.loginAction}" method="post">
                <input type="text" id="username" name="username" value="${username!''}" autocomplete="username" readonly style="display:none;" />

                <div class="form-group">
                    <label for="password-new">${msg("passwordNew")}</label>
                    <input type="password" id="password-new" name="password-new"
                           autofocus autocomplete="new-password" />
                </div>

                <div class="form-group">
                    <label for="password-confirm">${msg("passwordConfirm")}</label>
                    <input type="password" id="password-confirm" name="password-confirm"
                           autocomplete="new-password" />
                </div>

                <div class="checkbox-row">
                    <input type="checkbox" id="logout-sessions" name="logout-sessions" value="on" checked />
                    <label for="logout-sessions" style="margin:0;">${msg("logoutOtherSessions")}</label>
                </div>

                <button type="submit" class="submit-button">${msg("doSubmit")}</button>
            </form>
        </div>

        <div class="image-container">
            <div class="slide slide1 active"></div>
            <div class="slide slide2"></div>
            <div class="slide slide3"></div>
            <div class="slide slide4"></div>
            <div class="slide slide5"></div>
            <div class="overlay"></div>
            <div class="image-content">
                <h2>Free Evaluation System Framework</h2>
                <p class="author">DKRZ</p>
            </div>
            <div class="pagination">
                <span id="current-slide">1</span> of <span>5</span>
                <button aria-label="Previous" id="prev-slide"><</button>
                <button aria-label="Next" id="next-slide">></button>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const slides = document.querySelectorAll('.slide');
            const totalSlides = slides.length;
            let currentSlide = 0;
            const slideCounter = document.getElementById('current-slide');
            const prevButton = document.getElementById('prev-slide');
            const nextButton = document.getElementById('next-slide');

            let slideInterval = setInterval(nextSlide, 5000);

            function showSlide(n) {
                slides.forEach(s => s.classList.remove('active'));
                slides[n].classList.add('active');
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

            prevButton.addEventListener('click', function () {
                clearInterval(slideInterval);
                prevSlide();
                slideInterval = setInterval(nextSlide, 5000);
            });

            nextButton.addEventListener('click', function () {
                clearInterval(slideInterval);
                nextSlide();
                slideInterval = setInterval(nextSlide, 5000);
            });
        });
    </script>
</body>
</html>
