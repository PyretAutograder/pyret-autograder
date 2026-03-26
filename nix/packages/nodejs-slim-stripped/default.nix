{
  runCommand,
  removeReferencesTo,
  nodejs-slim,
  icu,
  openssl,
  sqlite,
  zlib,
  libuv,
  ...
}:
runCommand "nodejs-slim-stripped"
  {
    nativeBuildInputs = [ removeReferencesTo ];

    meta = {
      mainProgram = "node";
      description = "Node.js with dev references stripped";
    };

    disallowedReferences = [ nodejs-slim ];
  }
  ''
    mkdir -p $out/bin
    cp ${nodejs-slim}/bin/node $out/bin/node

    remove-references-to -t ${icu.dev} $out/bin/node
    remove-references-to -t ${openssl.dev} $out/bin/node
    remove-references-to -t ${sqlite.dev} $out/bin/node
    remove-references-to -t ${zlib.dev} $out/bin/node
    remove-references-to -t ${libuv.dev} $out/bin/node

    remove-references-to -t ${nodejs-slim} $out/bin/node
  ''
