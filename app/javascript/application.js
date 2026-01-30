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

// Loading Overlay Management
function showLoading() {
  const overlay = document.getElementById('loading-overlay');
  if (overlay) {
    overlay.style.display = 'flex';
  }
}

function hideLoading() {
  const overlay = document.getElementById('loading-overlay');
  if (overlay) {
    overlay.style.display = 'none';
  }
}

// Show loading on form submission (create/update profiles)
function setupProfileFormLoading() {
  const profileForms = document.querySelectorAll('form.profile-form');
  
  profileForms.forEach(function(form) {
    form.addEventListener('submit', function(e) {
      // Only show loading if the form is valid
      if (form.checkValidity()) {
        showLoading();
      }
    });
  });
}

// Show loading on rescan button click
function setupRescanButtonLoading() {
  const rescanButtons = document.querySelectorAll('form[action*="rescan"] button[type="submit"], button[data-loading="true"]');
  
  rescanButtons.forEach(function(button) {
    button.addEventListener('click', function() {
      showLoading();
    });
  });
  
  // Also handle form submission for button_to
  const rescanForms = document.querySelectorAll('form[action*="rescan"]');
  rescanForms.forEach(function(form) {
    form.addEventListener('submit', function() {
      showLoading();
    });
  });
}

// Hide loading when Turbo finishes loading
function setupTurboLoadingHandlers() {
  // Hide loading when page finishes loading
  document.addEventListener('turbo:load', function() {
    hideLoading();
  });
  
  document.addEventListener('turbo:frame-load', function() {
    hideLoading();
  });
  
  // Hide loading on navigation
  document.addEventListener('turbo:visit', function() {
    hideLoading();
  });
  
  // Hide loading if there's an error during fetch
  document.addEventListener('turbo:before-fetch-response', function(event) {
    const response = event.detail.fetchResponse;
    if (response && !response.succeeded) {
      setTimeout(hideLoading, 500);
    }
  });
  
  // Fallback: hide loading after a timeout (safety measure)
  let loadingTimeout;
  const originalShowLoading = window.showLoading || showLoading;
  window.showLoading = function() {
    originalShowLoading();
    clearTimeout(loadingTimeout);
    loadingTimeout = setTimeout(function() {
      hideLoading();
    }, 60000); // Hide after 60 seconds max
  };
}

// Initialize on page load
function initializeLoading() {
  setupProfileFormLoading();
  setupRescanButtonLoading();
  setupTurboLoadingHandlers();
}

document.addEventListener('DOMContentLoaded', function() {
  autoDismissAlerts();
  initializeLoading();
});

document.addEventListener('turbo:load', function() {
  autoDismissAlerts();
  initializeLoading();
});