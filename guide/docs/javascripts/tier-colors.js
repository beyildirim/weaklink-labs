document.addEventListener('DOMContentLoaded', function() {
  var path = window.location.pathname;
  var tierMatch = path.match(/tier-(\d+)/);
  if (tierMatch) {
    document.body.classList.add('tier-' + tierMatch[1]);
  }
});
