// Flutter Bootstrap Fallback Script
// This file provides a fallback for Flutter web bootstrap

(function() {
  'use strict';

  // Check if Flutter is already loaded
  if (window.flutter_bootstrap) {
    console.log('Flutter bootstrap already loaded');
    return;
  }

  // Create a simple loading screen
  function createLoadingScreen() {
    const loadingDiv = document.createElement('div');
    loadingDiv.id = 'flutter-loading';
    loadingDiv.innerHTML = `
      <div style="
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        display: flex;
        justify-content: center;
        align-items: center;
        background: linear-gradient(135deg, #000000 0%, #1a0000 50%, #8b0000 100%);
        color: white;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        z-index: 9999;
      ">
        <div style="text-align: center; padding: 20px;">
          <div style="
            width: 80px;
            height: 80px;
            margin: 0 auto 20px;
            border: 4px solid #8b0000;
            border-top: 4px solid transparent;
            border-radius: 50%;
            animation: spin 1s linear infinite;
          "></div>
          <h1 style="
            margin: 0 0 10px 0;
            color: #8b0000;
            font-size: 28px;
            font-weight: bold;
          ">Runner Code</h1>
          <p style="
            margin: 0 0 20px 0;
            font-size: 16px;
            opacity: 0.8;
          ">Professional Programming Education & IT Services</p>
          <p style="
            margin: 0;
            font-size: 14px;
            opacity: 0.6;
          ">Loading application...</p>
        </div>
      </div>
      <style>
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      </style>
    `;
    document.body.appendChild(loadingDiv);
  }

  // Remove loading screen
  function removeLoadingScreen() {
    const loadingDiv = document.getElementById('flutter-loading');
    if (loadingDiv) {
      loadingDiv.remove();
    }
  }

  // Initialize Flutter bootstrap
  function initFlutterBootstrap() {
    console.log('Initializing Flutter bootstrap...');
    
    // Create loading screen
    createLoadingScreen();

    // Simulate Flutter loading (in real scenario, this would be handled by Flutter)
    setTimeout(() => {
      removeLoadingScreen();
      console.log('Flutter bootstrap completed');
    }, 2000);
  }

  // Export flutter_bootstrap function
  window.flutter_bootstrap = function() {
    initFlutterBootstrap();
  };

  // Auto-initialize if DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initFlutterBootstrap);
  } else {
    initFlutterBootstrap();
  }

})();
