// Sidebar pin/unpin toggle
// Adds a button to collapse the left sidebar for more reading space
(function() {
  'use strict';

  var STORAGE_KEY = 'wl-sidebar-pinned';
  var toggleBtn = null;
  var restoreBtn = null;
  var pinned = localStorage.getItem(STORAGE_KEY) !== 'false'; // default: pinned (visible)

  function applyState() {
    document.body.classList.toggle('sidebar-hidden', !pinned);
    if (toggleBtn) {
      toggleBtn.textContent = pinned ? 'Unpin' : 'Pin';
      toggleBtn.title = pinned ? 'Hide sidebar' : 'Show sidebar';
    }
  }

  function toggle() {
    pinned = !pinned;
    localStorage.setItem(STORAGE_KEY, pinned ? 'true' : 'false');
    applyState();
  }

  function ensureToggleBtn() {
    var sidebar = document.querySelector('.md-sidebar--primary');
    if (!sidebar) return;

    // Don't duplicate
    if (sidebar.querySelector('.sidebar-toggle-btn')) return;

    toggleBtn = document.createElement('button');
    toggleBtn.className = 'sidebar-toggle-btn';
    toggleBtn.type = 'button';
    toggleBtn.addEventListener('click', function(e) {
      e.stopPropagation();
      toggle();
    });

    sidebar.style.position = 'relative';
    sidebar.appendChild(toggleBtn);
  }

  function ensureRestoreBtn() {
    if (restoreBtn) return;

    restoreBtn = document.createElement('button');
    restoreBtn.className = 'sidebar-restore-btn';
    restoreBtn.type = 'button';
    restoreBtn.textContent = 'Show sidebar';
    restoreBtn.addEventListener('click', function(e) {
      e.stopPropagation();
      toggle();
    });

    document.body.appendChild(restoreBtn);
  }

  function init() {
    ensureToggleBtn();
    ensureRestoreBtn();
    applyState();
  }

  if (typeof document$ !== 'undefined') {
    document$.subscribe(function() { init(); });
  } else {
    document.addEventListener('DOMContentLoaded', init);
  }
})();
