// This script handles the functionality of the Keycloak login page.


// Wait for DOM content to load
document.addEventListener('DOMContentLoaded', function() {
    const socialButtons = document.querySelectorAll('.social-button');
    const paginationButtons = document.querySelectorAll('.pagination button');
    
    // click handlers for social buttons
    if (socialButtons) {
        socialButtons.forEach(button => {
            button.addEventListener('click', function(e) {
                if (!this.form) {
                    e.preventDefault();
                }
            });
        });
    }
    
    // pagination slides
    if (paginationButtons) {
        let currentSlide = 1;
        const totalSlides = 5; // important: change this based on the number of slides
        
        paginationButtons.forEach(button => {
            button.addEventListener('click', function() {
                if (this.innerText === '<') {
                    currentSlide = Math.max(1, currentSlide - 1);
                } else {
                    currentSlide = Math.min(totalSlides, currentSlide + 1);
                }
                
                // Update slide counter
                const slideCounters = document.querySelectorAll('.pagination span');
                if (slideCounters && slideCounters[0]) {
                    slideCounters[0].innerText = currentSlide;
                }
            });
        });
    }
    
    
    // Input field styles
    const inputFields = document.querySelectorAll('input');
    if (inputFields) {
        inputFields.forEach(field => {

            field.addEventListener('focus', function() {
                this.parentElement.classList.add('focused');
            });
            
            field.addEventListener('blur', function() {
                if (!this.value) {
                    this.parentElement.classList.remove('focused');
                }
            });
            
            // when field already has a value (e.g., from autofill)
            if (field.value) {
                field.parentElement.classList.add('focused');
            }
        });
    }
});