// Lab verification button - calls the workstation verify API and shows results inline.
(function() {
  'use strict';

  var VERIFY_URL = 'http://localhost:7682/verify/';
  var btn = null;
  var resultBox = null;

  function getLabId() {
    var match = window.location.pathname.match(/\/labs\/tier-\d+\/(\d+\.\d+)/);
    return match ? match[1] : null;
  }

  function createButton() {
    if (btn) return;
    var labId = getLabId();
    if (!labId) return;

    var container = document.createElement('div');
    container.className = 'verify-container';

    btn = document.createElement('button');
    btn.className = 'verify-btn';
    btn.textContent = 'Verify Lab';
    btn.addEventListener('click', function() { runVerify(labId); });

    resultBox = document.createElement('div');
    resultBox.className = 'verify-result';

    container.appendChild(btn);
    container.appendChild(resultBox);

    var content = document.querySelector('.md-content__inner');
    if (content) content.appendChild(container);
  }

  function renderResult(data) {
    resultBox.textContent = '';
    resultBox.className = data.passed ? 'verify-result verify-pass' : 'verify-result verify-fail';

    var header = document.createElement('div');
    header.className = 'verify-header';
    header.textContent = data.passed ? '\u2713 Lab passed' : '\u2717 Not yet complete';
    resultBox.appendChild(header);

    if (data.checks && data.checks.length) {
      var checksDiv = document.createElement('div');
      checksDiv.className = 'verify-checks';
      data.checks.forEach(function(c) {
        var row = document.createElement('div');
        row.className = 'verify-check verify-check-' + c.status;
        var icon = c.status === 'pass' ? '\u2713 ' : c.status === 'fail' ? '\u2717 ' : '\u2022 ';
        row.textContent = icon + c.message;
        checksDiv.appendChild(row);
      });
      resultBox.appendChild(checksDiv);
    }

    if (data.error) {
      var errDiv = document.createElement('div');
      errDiv.className = 'verify-error';
      errDiv.textContent = data.error;
      resultBox.appendChild(errDiv);
    }
  }

  function runVerify(labId) {
    btn.disabled = true;
    btn.textContent = 'Verifying...';
    resultBox.className = 'verify-result';
    resultBox.textContent = '';

    fetch(VERIFY_URL + labId)
      .then(function(r) { return r.json(); })
      .then(function(data) {
        btn.disabled = false;
        btn.textContent = 'Verify Lab';
        renderResult(data);
      })
      .catch(function() {
        btn.disabled = false;
        btn.textContent = 'Verify Lab';
        resultBox.className = 'verify-result verify-fail';
        resultBox.textContent = '';
        var header = document.createElement('div');
        header.className = 'verify-header';
        header.textContent = '\u2717 Could not reach workstation';
        resultBox.appendChild(header);
        var err = document.createElement('div');
        err.className = 'verify-error';
        err.textContent = 'Make sure the lab environment is running.';
        resultBox.appendChild(err);
      });
  }

  function destroyButton() {
    if (btn) {
      var container = btn.parentNode;
      if (container) container.remove();
      btn = null;
      resultBox = null;
    }
  }

  function onNavigate() {
    var labId = getLabId();
    if (labId) {
      destroyButton();
      createButton();
    } else {
      destroyButton();
    }
  }

  if (typeof document$ !== 'undefined') {
    document$.subscribe(function() { onNavigate(); });
  } else {
    document.addEventListener('DOMContentLoaded', onNavigate);
  }
})();
