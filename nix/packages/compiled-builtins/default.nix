{
  buildNpmPackageCanvas,
  pyret-lang-src,
  cpo-src,
  ...
}:
# at runtime, the repl needs to have access to pre-compiled built-in modules
buildNpmPackageCanvas {
  name = "compiled-builtins";

  src = pyret-lang-src;
  needsCanvas = true;

  # npmDepsHash = lib.fakeHash;
  npmDepsHash = "sha256-fYR/67nbU9hZTX9K8Oc8IVNe0RylKwJQK7rNwvTMISE=";

  buildPhase = ''
    runHook preBuild

    npm rebuild

    make phaseA libA

    mkdir -p build/cpo-compiled

    # if we compile directly, name will be wrong
    cat > build/compile-dcic.arr << 'EOF'
    import dcic2024 as _
    EOF

    # manually add dcic2024 context
    node build/phaseA/pyret.jarr \
      -allow-builtin-overrides \
      --builtin-js-dir src/js/trove/ \
      --builtin-arr-dir src/arr/trove/ \
      --builtin-arr-dir ${cpo-src}/src/web/arr/trove/ \
      --require-config src/scripts/standalone-configA.json \
      --compiled-dir build/cpo-compiled/ \
      --build-runnable build/compile-dcic.arr \
      --standalone-file src/js/base/handalone.js \
      --outfile build/compile-dcic.jarr \
      -no-check-mode

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r build/phaseA/lib-compiled $out/
    cp -r build/cpo-compiled $out/

    runHook postInstall
  '';
}
