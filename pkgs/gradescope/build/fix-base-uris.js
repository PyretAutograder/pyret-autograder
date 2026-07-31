// Re-insert the file:// scheme that the autograder-lib build sed strips from
// module URIs.
//
// gradescope-build/default.nix rewrites compiled autograder-lib references from
// the workspace-prepared path to the in-image node_modules path with:
//     sed -i "s|[^\"]*workspace-prepared/pkgs/core/|$NODE_MODULES/pyret-autograder/|g"
// Because [^"]* also matches the "file://" scheme, the rewritten reference ends
// up as a bare '"/nix/store/<hash>-...-build/node_modules/...arr' (quote directly
// before /nix/store), so the flatness checker can't resolve it and gen_autograder
// fails with `Key .../grading.arr not found`. The correct form is
// '"file:///nix/store/...'. This restores the missing scheme.
//
// The store path is auto-discovered, so this works for any base image built from
// this fork without a hardcoded nix-store hash.
//
// NOTE: the proper fix is in the sed itself (emit the file:// scheme); this is
// the docker-build-time counterpart used until the base is rebuilt with that fix.
var fs = require('fs');
var path = require('path');

var roots = fs.readdirSync('/nix/store')
  .filter(function (f) { return f.endsWith('-pyret-autograder-gradescope-build'); })
  .map(function (f) { return '/nix/store/' + f; })
  .filter(function (d) {
    try { return fs.statSync(d + '/share/pyret-autograder/autograder-lib').isDirectory(); }
    catch (e) { return false; }
  });

if (roots.length === 0) {
  console.error('fix-base-uris: no -pyret-autograder-gradescope-build store path with autograder-lib found');
  process.exit(1);
}

var STORE_ROOT = roots[0];
var LIB = STORE_ROOT + '/share/pyret-autograder/autograder-lib';

// Broken references are: <quote>/nix/store/<hash>-...-build/node_modules/...
// Correct references are: <quote>file:///nix/store/<hash>-...-build/node_modules/...
var BROKEN = STORE_ROOT + '/node_modules/';
function escapeRe(s) { return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); }
var re = new RegExp('(["\'])' + escapeRe(BROKEN), 'g');

var totalReplaced = 0, filesFixed = 0;
fs.readdirSync(LIB).filter(function (f) { return f.endsWith('.js'); }).forEach(function (f) {
  var full = path.join(LIB, f);
  var content = fs.readFileSync(full, 'utf8');
  var replaced = 0;
  var fixed = content.replace(re, function (_m, q) { replaced++; return q + 'file://' + BROKEN; });
  if (replaced > 0) {
    fs.writeFileSync(full, fixed);
    totalReplaced += replaced;
    filesFixed++;
  }
});

console.log('fix-base-uris: added file:// scheme to ' + totalReplaced +
  ' URI(s) in ' + filesFixed + ' file(s) [' + path.basename(STORE_ROOT) + ']');
