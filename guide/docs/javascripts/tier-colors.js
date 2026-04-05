// Apply tier-specific body class based on URL path.
// Handles both initial load and MkDocs Material instant navigation.
function applyTierColor() {
  // Remove all existing tier classes first
  document.body.className = document.body.className.replace(/\btier-\d+\b/g, '').trim();

  var path = window.location.pathname;
  var tierMatch = path.match(/tier-(\d+)/);
  if (tierMatch) {
    document.body.classList.add('tier-' + tierMatch[1]);
  }
}

if (typeof document$ !== 'undefined') {
  document$.subscribe(function() { applyTierColor(); });
} else {
  document.addEventListener('DOMContentLoaded', applyTierColor);
}
