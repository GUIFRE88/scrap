import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"

function autoDismissAlerts() {
  const alerts = document.querySelectorAll('.alert.alert-dismissible');
  
  alerts.forEach(function(alert) {
    if (!alert.classList.contains('show')) {
      return;
    }
    
    setTimeout(function() {
      const closeButton = alert.querySelector('.btn-close');
      if (closeButton) {
        closeButton.click();
      } else {
        alert.classList.remove('show');
        setTimeout(function() {
          alert.remove();
        }, 150);
      }
    }, 5000);
  });
}

document.addEventListener('DOMContentLoaded', autoDismissAlerts);

document.addEventListener('turbo:load', autoDismissAlerts);