/** @satisfies {PyretModule} */
({
  requires: [
    { "import-type": "dependency", protocol: "js-file", args: ["./bridge"] },
    { "import-type": "builtin", name: "load-lib" },
  ],
  // nativeRequires: [
  //   "pyret-base/js/exn-stack-parser",
  // ],
  nativeRequires: [],
  provides: {
    values: {
      // TODO: figure out the module types
      "save-module-result-image": ["arrow", ["Any"], "Any"],
    },
  },
  theModule: function (runtime, _ns, _uri, bridge, loadLib) {
    "use strict";

    /** @typedef {{val: { runtime: PyretRuntime; result: any; program: any; realm: any; } }} ModuleReturn */

    /**
     * @param {ModuleReturn} mr
     * @param {string} field
     */
    function checkSuccess(mr, field) {
      if (!mr.val) {
        console.error(mr);
        runtime.ffi.throwMessageException(`Tried to get ${field} of non-successful module compilation.`);
      }
      if (!mr.val.runtime.isSuccessResult(mr.val.result)) {
        console.error(mr.val.result);
        console.error(mr.val.result.exn);
        runtime.ffi.throwMessageException(`Tried to get ${field} of non-successful module execution.`);
      }
    }

    /**
     * @param {ModuleReturn} mr
     */
    function saveModuleResultImage(mr) {
      checkSuccess(mr, "answer");
      const foreignRt = mr.val.runtime;
      const [gf, gmf] = bridge.rtHelpers(runtime);
      const [fgf, fgmf] = bridge.rtHelpers(foreignRt);

      const llInternal = gf(loadLib, "internal");
      const ans = llInternal.getModuleResultAnswer(mr);
      const img = bridge.getMod(foreignRt, "builtin://image");
      const saveImage = fgmf(img, "save-image");

      return foreignRt.safeCall(() => {
        saveImage.app(ans, "./test.png");
        return foreignRt.nothing;
      }, (_) => {
        return runtime.makeNumber(0);
      }, "save-image");
    }

    return runtime.makeModuleReturn({
      "save-module-result-image": runtime.makeFunction(saveModuleResultImage, "save-module-result-image"),
    }, {});
  },
})
