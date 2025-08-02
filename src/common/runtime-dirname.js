// prettier-ignore
({
  requires: [],
  provides: {
    values: {
      "runtime-dirname": ["arrow", [], "String"],
    },
  },
  nativeRequires: [],
  theModule: function (runtime, _, _) {
    function runtimeDirname() {
      runtime.checkArity(0, arguments, false);
      return runtime.makeString(__dirname);
    }

    return runtime.makeModuleReturn({
      "runtime-dirname": runtime.makeFunction(runtimeDirname, "runtime-dirname")
    }, {});
  },
})
