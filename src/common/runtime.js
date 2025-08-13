/** @satisfies {PyretModule} */
({
  requires: [],
  provides: {
    values: {
      "runtime-dirname": ["arrow", [], "String"],
      "get-env": ["arrow", [], ["Option", "String"]]
    },
  },
  nativeRequires: [],
  theModule: function (runtime, _namespace, _uri) {
    "use strict";
    function runtimeDirname() {
      runtime.checkArity(0, arguments, "runtime-dirname", false);
      return runtime.makeString(__dirname);
    }

    /**
      * @param {string} name
      */
    function getEnv(name) {
      runtime.checkArity(1, arguments, "get-env", false);
      runtime.checkString(name);

      const val = process.env[name];
      if (val != null) {
        return runtime.ffi.makeSome(runtime.makeString(val));
      } else {
        return runtime.ffi.makeNone();
      }
    }

    return runtime.makeModuleReturn({
      "runtime-dirname": runtime.makeFunction(runtimeDirname, "runtime-dirname"),
      "get-env": runtime.makeFunction(getEnv, "get-env"),
    }, {});
  },
})
