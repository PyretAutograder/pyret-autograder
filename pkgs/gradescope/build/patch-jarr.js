// Patch autograder.jarr to delete the "definitions://" cache files before
// each call to restart-interactions, preventing stale compiled programs from
// being reused across tests.
var fs = require('fs');
var jarPath = process.argv[2];
var c = fs.readFileSync(jarPath, 'utf8');

var DEF_HASH = '0c7f739838d9820c63f315aec95da7c9888d64abd744be6ad05d68a9be553de0';
var snippet = "(function(){try{var _fs=require('fs'),_p=require('path'),_d=process.env.PA_CACHE_BASE_DIR||'./.pyret/compiled',_h='definitions-" + DEF_HASH + "';['-module.js','-static.js'].forEach(function(s){try{_fs.unlinkSync(_p.join(_d,_h+s));}catch(e){}});}catch(e){}})();";

var pat = /(\$ans\d+) = (R\.maybeMethodCall2\([^,]+,\\"restart-interactions\\",)/g;
var count = (c.match(pat) || []).length;
var patched = c.replace(pat, snippet + '$1 = $2');
fs.writeFileSync(jarPath, patched);
console.log('patch-jarr: inserted cache-deletion before ' + count + ' restart-interactions call(s)');
