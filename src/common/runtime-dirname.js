/** @satisfies {PyretModule} */
({
  requires: [],
  provides: {
    values: {
      "runtime-dirname": ["arrow", [], "String"],
    },
  },
  nativeRequires: [],
  theModule: function (runtime, _namespace, _uri) {
    function runtimeDirname() {
      runtime.checkArity(0, arguments, "runtime-dirname", false);
      return runtime.makeString(__dirname);
    }

    return runtime.makeModuleReturn({
      "runtime-dirname": runtime.makeFunction(runtimeDirname, "runtime-dirname")
    }, {});
  },
})
