{
  runCommand,
  removeReferencesTo,
  nodejs,
  icu,
  openssl,
  sqlite,
  zlib,
  libuv,
  ...
}:
let
  node-js-slim = nodejs.override { enableNpm = false; };
in
runCommand "nodejs-slim-stripped"
  {
    nativeBuildInputs = [ removeReferencesTo ];

    meta = {
      mainProgram = "node";
      description = "Node.js with dev references stripped";
    };

    disallowedReferences = [ node-js-slim ];
  }
  ''
    mkdir -p $out/bin
    cp ${node-js-slim}/bin/node $out/bin/node

    remove-references-to -t ${icu.dev} $out/bin/node
    remove-references-to -t ${openssl.dev} $out/bin/node
    remove-references-to -t ${sqlite.dev} $out/bin/node
    remove-references-to -t ${zlib.dev} $out/bin/node
    remove-references-to -t ${libuv.dev} $out/bin/node

    remove-references-to -t ${node-js-slim} $out/bin/node
  ''
