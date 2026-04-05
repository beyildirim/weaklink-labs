// Persistent bottom terminal panel for lab pages
(function() {
  'use strict';

  // Only show on lab pages
  if (!window.location.pathname.includes('/labs/')) return;

  // Build panel via safe DOM methods
  var panel = document.createElement('div');
  panel.className = 'terminal-panel collapsed';

  var header = document.createElement('div');
  header.className = 'terminal-panel-header';

  var title = document.createElement('span');
  title.className = 'terminal-panel-title';
  title.textContent = 'Terminal';

  var controls = document.createElement('div');
  controls.className = 'terminal-panel-controls';

  var toggleBtn = document.createElement('button');
  toggleBtn.className = 'terminal-panel-btn';
  toggleBtn.dataset.action = 'toggle';
  toggleBtn.textContent = 'Open';

  var resizeBtn = document.createElement('button');
  resizeBtn.className = 'terminal-panel-btn';
  resizeBtn.dataset.action = 'resize';
  resizeBtn.textContent = 'Resize';

  controls.appendChild(toggleBtn);
  controls.appendChild(resizeBtn);
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

  var sizes = ['40vh', '55vh', '25vh'];
  var sizeIndex = 0;

  function toggle() {
    panel.classList.toggle('collapsed');
    var isOpen = !panel.classList.contains('collapsed');
    document.body.classList.toggle('terminal-open', isOpen);
    toggleBtn.textContent = isOpen ? 'Collapse' : 'Open';
  }

  header.addEventListener('click', function(e) {
    if (e.target.dataset.action === 'resize') return;
    toggle();
  });

  toggleBtn.addEventListener('click', function(e) {
    e.stopPropagation();
    toggle();
  });

  resizeBtn.addEventListener('click', function(e) {
    e.stopPropagation();
    sizeIndex = (sizeIndex + 1) % sizes.length;
    panel.style.height = sizes[sizeIndex];
  });
})();
