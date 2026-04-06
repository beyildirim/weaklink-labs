// Placement quiz - browser-based version of `weaklink assess`
(function() {
  'use strict';

  var QUESTIONS = [
    {q: 'What does `git diff HEAD~1` show?', opts: ['changes in last commit', 'staged changes', 'untracked files', 'merge conflicts'], answer: 0, topic: 'Git'},
    {q: 'What prevents direct pushes to main?', opts: ['.gitignore', 'branch protection rules', 'git hooks only', 'repository permissions'], answer: 1, topic: 'Git'},
    {q: 'In a supply chain attack via Git, an attacker would most likely:', opts: ['delete the repo', 'modify a build script in a PR', 'change the README', 'add a .gitignore'], answer: 1, topic: 'Git'},
    {q: 'When you run `pip install <package>`, what file can execute arbitrary code?', opts: ['README.md', 'setup.py', 'requirements.txt', '__init__.py'], answer: 1, topic: 'Package Managers'},
    {q: 'What does `--extra-index-url` do in pip?', opts: ['replaces the default registry', 'adds an additional registry to check', 'disables the cache', 'enables verbose mode'], answer: 1, topic: 'Package Managers'},
    {q: 'What is a lockfile?', opts: ['a file that prevents package installation', 'an exact snapshot of all dependency versions', 'a password file for private registries', 'a log of all pip commands'], answer: 1, topic: 'Package Managers'},
    {q: 'What does `--require-hashes` do?', opts: ['encrypts packages', 'verifies package integrity via checksums', 'hashes the requirements file', 'enables TLS'], answer: 1, topic: 'Package Managers'},
    {q: 'Docker tags like `:latest` are:', opts: ['immutable, always point to the same image', 'mutable, can be reassigned to different images', 'only used in development', 'automatically versioned'], answer: 1, topic: 'Containers'},
    {q: 'What uniquely identifies a Docker image regardless of tag changes?', opts: ['image name', 'tag', 'digest (sha256 hash)', 'Dockerfile'], answer: 2, topic: 'Containers'},
    {q: 'An attacker who pushes a new image with the same tag is performing:', opts: ['registry confusion', 'tag poisoning', 'layer injection', 'manifest confusion'], answer: 1, topic: 'Containers'}
  ];

  var PASS_THRESHOLD = 8;
  var currentQ = 0;
  var score = 0;
  var wrongTopics = [];

  function init() {
    var container = document.getElementById('placement-quiz');
    if (!container) return;

    container.textContent = '';

    var startBtn = document.createElement('button');
    startBtn.className = 'verify-btn';
    startBtn.textContent = 'Start Placement Test';
    startBtn.addEventListener('click', function() {
      currentQ = 0;
      score = 0;
      wrongTopics = [];
      container.textContent = '';
      showQuestion(container);
    });
    container.appendChild(startBtn);
  }

  function showQuestion(container) {
    if (currentQ >= QUESTIONS.length) {
      showResult(container);
      return;
    }

    container.textContent = '';
    var q = QUESTIONS[currentQ];

    var progress = document.createElement('div');
    progress.className = 'quiz-progress';
    progress.textContent = (currentQ + 1) + ' / ' + QUESTIONS.length;
    container.appendChild(progress);

    var topic = document.createElement('span');
    topic.className = 'quiz-topic';
    topic.textContent = q.topic;
    container.appendChild(topic);

    var question = document.createElement('div');
    question.className = 'quiz-question';
    question.textContent = q.q;
    container.appendChild(question);

    var optionsDiv = document.createElement('div');
    optionsDiv.className = 'quiz-options';

    q.opts.forEach(function(opt, i) {
      var btn = document.createElement('button');
      btn.className = 'quiz-option';
      btn.textContent = String.fromCharCode(97 + i) + ') ' + opt;
      btn.addEventListener('click', function() {
        handleAnswer(container, i, btn, optionsDiv);
      });
      optionsDiv.appendChild(btn);
    });

    container.appendChild(optionsDiv);
  }

  function handleAnswer(container, selected, btn, optionsDiv) {
    var q = QUESTIONS[currentQ];
    var buttons = optionsDiv.querySelectorAll('.quiz-option');

    // Disable all buttons
    buttons.forEach(function(b) { b.disabled = true; });

    if (selected === q.answer) {
      btn.classList.add('correct');
      score++;
    } else {
      btn.classList.add('wrong');
      buttons[q.answer].classList.add('correct');
      if (wrongTopics.indexOf(q.topic) === -1) {
        wrongTopics.push(q.topic);
      }
    }

    currentQ++;
    setTimeout(function() {
      showQuestion(container);
    }, 800);
  }

  function showResult(container) {
    container.textContent = '';

    var passed = score >= PASS_THRESHOLD;

    var result = document.createElement('div');
    result.className = 'quiz-result ' + (passed ? 'quiz-pass' : 'quiz-fail');

    var scoreDiv = document.createElement('div');
    scoreDiv.className = 'quiz-score';
    scoreDiv.textContent = score + ' / ' + QUESTIONS.length;
    result.appendChild(scoreDiv);

    var msg = document.createElement('div');
    msg.className = 'quiz-message';
    if (passed) {
      msg.textContent = 'You passed! Labs 0.1, 0.2, and 0.3 can be skipped. Jump to Tier 1: Package Security.';
    } else {
      msg.textContent = 'We recommend completing Tier 0 labs.';
      if (wrongTopics.length > 0) {
        var areas = document.createElement('div');
        areas.className = 'quiz-weak-areas';
        areas.textContent = 'Review: ' + wrongTopics.join(', ');
        result.appendChild(areas);
      }
    }
    result.appendChild(msg);

    var retryBtn = document.createElement('button');
    retryBtn.className = 'quiz-retry';
    retryBtn.textContent = 'Retake';
    retryBtn.addEventListener('click', function() {
      currentQ = 0;
      score = 0;
      wrongTopics = [];
      container.textContent = '';
      showQuestion(container);
    });
    result.appendChild(retryBtn);

    container.appendChild(result);
  }

  if (typeof document$ !== 'undefined') {
    document$.subscribe(function() { init(); });
  } else {
    document.addEventListener('DOMContentLoaded', init);
  }
})();
