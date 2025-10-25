/** @satisfies {PyretModule} */
({
  requires: [
    { "import-type": "dependency", protocol: "js-file", args: ["./bridge"] },
    { "import-type": "builtin", name: "load-lib" },
  ],
  nativeRequires: ["node:path"],
  provides: {
    values: {
      // TODO: figure out the module types
      "save-module-result-image": ["arrow", ["Any"], "Any"],
    },
  },
  /**
   * @param {import("node:path")} path
   */
  theModule: function (runtime, _ns, _uri, bridge, loadLib, path) {
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
     * @param {string} savePath
     */
    function saveModuleResultImage(mr, savePath) {
      runtime.checkArity(2, arguments, "save-module-result-image", false);
      runtime.checkOpaque(mr);
      runtime.checkString(savePath);

      checkSuccess(mr, "answer");

      if (path.isAbsolute(savePath)) {
        return runtime.ffi.makeLeft(runtime.makeString("unexpected absolute path"));
      }

      const fullPath = path.join(
        process.env.PA_ARTIFACT_DIR ?? ".",
        savePath
      );

      return runtime.pauseStack((restarter) => {
        const foreignRt = mr.val.runtime;
        const [gf, gmf] = bridge.rtHelpers(runtime);
        const [fgf, fgmf] = bridge.rtHelpers(foreignRt);

        const llInternal = gf(loadLib, "internal");
        const ans = llInternal.getModuleResultAnswer(mr);
        const img = bridge.getMod(foreignRt, "builtin://image");
        const saveImage = fgmf(img, "save-image");

        foreignRt.runThunk(() => {
          return foreignRt.safeCall(() => {
            return saveImage.app(ans, fullPath);
          }, (res) => {
            return res;
          }, "save-image");
        }, (/** @type {*} */ v) => {
          if (foreignRt.isSuccessResult(v)) {
            restarter.resume(runtime.ffi.makeRight(runtime.makeString(savePath)));
          } else if (foreignRt.isFailureResult(v)) {
            // const realm = gf(loadLib, "internal").getModuleResultRealm(mr);
            // const richStack = gf(loadLib, "internal").enrichStack(v.exn, realm);
            // console.dir([foreignRt.toRepr(v.exn.exn), richStack])
            // TODO: better error handling
            restarter.resume(runtime.ffi.makeLeft(v));
          } else {
            runtime.ffi.throwMessageException("invalid run thunk result");
          }
        });
      });
    }

    return runtime.makeModuleReturn({
      "save-module-result-image": runtime.makeFunction(saveModuleResultImage, "save-module-result-image"),
    }, {});
  },
})
