// Persistent terminal panel for lab pages (bottom or side).
// Handles both initial load and MkDocs Material instant navigation.
(function() {
  'use strict';

  var panel = null;
  var iframe = null;
  var iframeLoaded = false;
  var position = localStorage.getItem('wl-terminal-pos') || 'bottom';
  var isOpen = false;

  function createPanel() {
    if (panel) return;

    panel = document.createElement('div');
    panel.className = 'terminal-panel collapsed pos-' + position;

    var header = document.createElement('div');
    header.className = 'terminal-panel-header';

    var title = document.createElement('span');
    title.className = 'terminal-panel-title';
    title.textContent = 'Terminal';

    var controls = document.createElement('div');
    controls.className = 'terminal-panel-controls';

    var toggleBtn = document.createElement('button');
    toggleBtn.className = 'terminal-panel-btn';
    toggleBtn.textContent = 'Open';

    var dockBtn = document.createElement('button');
    dockBtn.className = 'terminal-panel-btn';
    dockBtn.textContent = position === 'bottom' ? 'Dock Right' : 'Dock Bottom';

    controls.appendChild(toggleBtn);
    controls.appendChild(dockBtn);
    header.appendChild(title);
    header.appendChild(controls);

    var body = document.createElement('div');
    body.className = 'terminal-panel-body';

    iframe = document.createElement('iframe');
    iframe.title = 'WeakLink Workstation Terminal';
    // Don't set src yet; load lazily on first open
    body.appendChild(iframe);

    panel.appendChild(header);
    panel.appendChild(body);
    document.body.appendChild(panel);

    header.addEventListener('click', function(e) {
      if (e.target === dockBtn) return;
      toggle();
    });

    toggleBtn.addEventListener('click', function(e) {
      e.stopPropagation();
      toggle();
    });

    dockBtn.addEventListener('click', function(e) {
      e.stopPropagation();
      switchPosition();
    });

    function toggle() {
      isOpen = !isOpen;
      panel.classList.toggle('collapsed', !isOpen);
      document.body.classList.toggle('terminal-' + position, isOpen);
      toggleBtn.textContent = isOpen ? 'Collapse' : 'Open';

      // Lazy-load iframe on first open
      if (isOpen && !iframeLoaded) {
        iframe.src = 'http://localhost:7681';
        iframeLoaded = true;
      }
    }

    function switchPosition() {
      var wasOpen = isOpen;
      if (wasOpen) {
        document.body.classList.remove('terminal-' + position);
      }
      position = position === 'bottom' ? 'right' : 'bottom';
      panel.classList.remove('pos-bottom', 'pos-right');
      panel.classList.add('pos-' + position);
      dockBtn.textContent = position === 'bottom' ? 'Dock Right' : 'Dock Bottom';
      localStorage.setItem('wl-terminal-pos', position);
      if (wasOpen) {
        document.body.classList.add('terminal-' + position);
      }
    }

    // If it was previously open (navigating between lab pages), restore state
    if (isOpen) {
      panel.classList.remove('collapsed');
      document.body.classList.add('terminal-' + position);
      toggleBtn.textContent = 'Collapse';
      if (!iframeLoaded) {
        iframe.src = 'http://localhost:7681';
        iframeLoaded = true;
      }
    }
  }

  function destroyPanel() {
    if (!panel) return;

    // Clean up body classes
    document.body.classList.remove('terminal-bottom', 'terminal-right');

    panel.remove();
    panel = null;
    iframe = null;
    iframeLoaded = false;
    isOpen = false;
  }

  function onNavigate() {
    var isLabPage = window.location.pathname.includes('/labs/');
    if (isLabPage && !panel) {
      createPanel();
    } else if (!isLabPage && panel) {
      destroyPanel();
    }
  }

  if (typeof document$ !== 'undefined') {
    document$.subscribe(function() { onNavigate(); });
  } else {
    document.addEventListener('DOMContentLoaded', onNavigate);
  }
})();
