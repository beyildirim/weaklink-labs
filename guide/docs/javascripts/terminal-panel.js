// Persistent terminal panel for lab pages (bottom or side)
(function() {
  'use strict';

  if (!window.location.pathname.includes('/labs/')) return;

  // State
  var position = localStorage.getItem('wl-terminal-pos') || 'bottom';
  var isOpen = false;

  // Build panel
  var panel = document.createElement('div');
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

  var iframe = document.createElement('iframe');
  iframe.src = 'http://localhost:7681';
  iframe.title = 'WeakLink Workstation Terminal';
  iframe.loading = 'lazy';
  body.appendChild(iframe);

  panel.appendChild(header);
  panel.appendChild(body);
  document.body.appendChild(panel);

  function toggle() {
    isOpen = !isOpen;
    panel.classList.toggle('collapsed', !isOpen);
    document.body.classList.toggle('terminal-open', isOpen);
    document.body.classList.toggle('terminal-' + position, isOpen);
    toggleBtn.textContent = isOpen ? 'Collapse' : 'Open';
  }

  function switchPosition() {
    var wasOpen = isOpen;
    if (wasOpen) {
      document.body.classList.remove('terminal-open', 'terminal-' + position);
    }
    position = position === 'bottom' ? 'right' : 'bottom';
    panel.classList.remove('pos-bottom', 'pos-right');
    panel.classList.add('pos-' + position);
    dockBtn.textContent = position === 'bottom' ? 'Dock Right' : 'Dock Bottom';
    localStorage.setItem('wl-terminal-pos', position);
    if (wasOpen) {
      document.body.classList.add('terminal-open', 'terminal-' + position);
    }
  }

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
})();
