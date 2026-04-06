// THM-style right-side split terminal panel for lab pages.
// States: split (active), collapsed (hidden + Show Split View btn), popped-out (same as collapsed).
// Auto-initializes the correct lab when navigating between lab pages.
(function() {
  'use strict';

  var panel = null;
  var iframe = null;
  var iframeLoaded = false;
  var splitBtn = null;
  var isOpen = localStorage.getItem('wl-terminal-open') === 'true';
  var currentLabId = null;

  function getLabId() {
    var match = window.location.pathname.match(/\/labs\/tier-\d+\/(\d+\.\d+)/);
    return match ? match[1] : null;
  }

  function buildTerminalUrl() {
    return 'http://localhost:7681';
  }

  function initLab(labId) {
    if (!labId) return;
    fetch('http://localhost:7682/set-lab/' + labId).catch(function() {});
  }

  function createPanel() {
    if (panel) return;

    panel = document.createElement('div');
    panel.className = 'terminal-panel';

    var header = document.createElement('div');
    header.className = 'terminal-panel-header';

    var title = document.createElement('span');
    title.className = 'terminal-panel-title';
    title.textContent = 'Workstation';

    var controls = document.createElement('div');
    controls.className = 'terminal-panel-controls';

    controls.appendChild(makeBtn('\u21BA', 'Reset Lab', resetLab));
    controls.appendChild(makeBtn('\u2197', 'Open in new tab', popout));
    controls.appendChild(makeBtn('\u2212', 'Collapse', collapse));

    header.appendChild(title);
    header.appendChild(controls);

    var body = document.createElement('div');
    body.className = 'terminal-panel-body';

    iframe = document.createElement('iframe');
    iframe.title = 'WeakLink Workstation Terminal';
    body.appendChild(iframe);

    panel.appendChild(header);
    panel.appendChild(body);
    document.body.appendChild(panel);

    // Show Split View button (floating, bottom-right)
    splitBtn = document.createElement('button');
    splitBtn.className = 'show-split-view-btn';
    splitBtn.textContent = 'Show Terminal';
    splitBtn.addEventListener('click', activate);
    document.body.appendChild(splitBtn);

    if (isOpen) {
      activate();
    } else {
      splitBtn.style.display = 'block';
    }
  }

  function makeBtn(text, tip, handler) {
    var b = document.createElement('button');
    b.className = 'terminal-panel-btn';
    b.textContent = text;
    b.title = tip;
    b.addEventListener('click', handler);
    return b;
  }

  function activate() {
    isOpen = true;
    localStorage.setItem('wl-terminal-open', 'true');
    if (panel) panel.classList.add('active');
    document.body.classList.add('terminal-split');
    if (splitBtn) splitBtn.style.display = 'none';

    var labId = getLabId();
    if (!iframeLoaded && iframe) {
      currentLabId = labId;
      initLab(labId);
      // Delay iframe load to let lab-init finish
      setTimeout(function() {
        iframe.src = buildTerminalUrl();
        iframeLoaded = true;
      }, 1500);
    } else if (labId && labId !== currentLabId && iframe) {
      // Lab changed: re-init and reload terminal for fresh shell
      currentLabId = labId;
      initLab(labId);
      iframeLoaded = false;
      iframe.src = '';
      setTimeout(function() {
        iframe.src = buildTerminalUrl();
        iframeLoaded = true;
      }, 1500);
    }
  }

  function collapse() {
    isOpen = false;
    localStorage.setItem('wl-terminal-open', 'false');
    if (panel) panel.classList.remove('active');
    document.body.classList.remove('terminal-split');
    if (splitBtn) splitBtn.style.display = 'block';
  }

  function popout() {
    window.open(buildTerminalUrl(), '_blank');
    collapse();
  }

  function resetLab() {
    var labId = getLabId();
    currentLabId = labId;
    initLab(labId);
    // Also reload the iframe to get a fresh shell
    if (iframe) {
      iframeLoaded = false;
      iframe.src = '';
      setTimeout(function() {
        iframe.src = buildTerminalUrl();
        iframeLoaded = true;
      }, 500);
    }
  }

  function destroyPanel() {
    document.body.classList.remove('terminal-split');
    if (panel) { panel.remove(); panel = null; }
    if (splitBtn) { splitBtn.remove(); splitBtn = null; }
    iframe = null;
    iframeLoaded = false;
  }

  function onNavigate() {
    var path = window.location.pathname;
    var isLabPage = path.includes('/labs/');
    var isReferencePage = path.match(/\/detect\/?$/);
    var showTerminal = isLabPage && !isReferencePage;

    if (showTerminal && !panel) {
      createPanel();
    } else if (showTerminal && panel && isOpen) {
      // Lab changed during navigation: re-init and reload terminal
      var labId = getLabId();
      if (labId && labId !== currentLabId && iframe) {
        currentLabId = labId;
        initLab(labId);
        iframeLoaded = false;
        iframe.src = '';
        setTimeout(function() {
          iframe.src = buildTerminalUrl();
          iframeLoaded = true;
        }, 1500);
      }
    } else if (!showTerminal && panel) {
      destroyPanel();
    }
  }

  if (typeof document$ !== 'undefined') {
    document$.subscribe(function() { onNavigate(); });
  } else {
    document.addEventListener('DOMContentLoaded', onNavigate);
  }
})();
