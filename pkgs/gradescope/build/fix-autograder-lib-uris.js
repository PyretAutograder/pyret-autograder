// Fix broken URIs in the published autograder-lib compiled modules.
// The buggy sed consumed the opening " and nix store prefix from URIs.
// Split on the SLASH + HASH pattern; if the tail before the split already ends
// with 'file:///nix/store', the URI is already correct — don't double-apply.
var fs = require('fs');
var path = require('path');

var STORE_HASH = '2ashmahcfs9i051ffyh6ifqrya72sgp7';
var AUTOGRADER_LIB = '/nix/store/' + STORE_HASH +
  '-pyret-autograder-gradescope-build/share/pyret-autograder/autograder-lib';

// Pattern WITH leading slash (the slash before the hash is part of the path)
var BROKEN = '/' + STORE_HASH + '-pyret-autograder-gradescope-build/node_modules/';
var CORRECT = 'file:///nix/store' + BROKEN;   // = 'file:///nix/store/bsb1...'
var ALREADY = 'file:///nix/store';              // what correct URIs end with before BROKEN

var files = fs.readdirSync(AUTOGRADER_LIB).filter(function(f) { return f.endsWith('.js'); });
var totalReplaced = 0;
var filesFixed = 0;

files.forEach(function(f) {
  var full = path.join(AUTOGRADER_LIB, f);
  var content = fs.readFileSync(full, 'utf8');
  var parts = content.split(BROKEN);
  if (parts.length <= 1) return;

  var fixed = parts[0];
  var replaced = 0;
  for (var i = 1; i < parts.length; i++) {
    // If 'fixed' ends with 'file:///nix/store', the next part is an
    // already-correct URI — just rejoin with BROKEN (restores the slash+hash).
    if (fixed.endsWith(ALREADY)) {
      fixed = fixed + BROKEN + parts[i];
    } else {
      // Broken URI — add the full correct nix-store prefix.
      fixed = fixed + CORRECT + parts[i];
      replaced++;
    }
  }
  if (replaced > 0) {
    fs.writeFileSync(full, fixed);
    totalReplaced += replaced;
    filesFixed++;
  }
});

console.log('fix-autograder-lib-uris: fixed ' + totalReplaced +
  ' broken URI(s) in ' + filesFixed + ' file(s)');
