/** @satisfies {PyretModule} */
({
  // requires: [
  //   { "import-type": "dependency", protocol: "js-file", args: ["./bridge"] },
  // ],
  // nativeRequires: [
  //   "pyret-base/js/exn-stack-parser",
  // ],
  requires: [
    { "import-type": "dependency", protocol: "js-file", args: ["./bridge"] },
  ],
  nativeRequires: ["canvas", "fs"],
  provides: {
    values: {
      // TODO: figure out the module types
      "get-module-result-answer": ["arrow", ["Any"], "Any"],
    }
  },
  theModule: function(runtime, _ns, _uri, bridge, canvas, fs) {
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
    function getModuleResultAnswer(mr) {
      checkSuccess(mr, "answer");
      const foreignRt = mr.val.runtime;
      const gf = foreignRt.getField;
      const ans = gf(mr.val.result.result, "answer");
      const img = bridge.getMod(foreignRt, "builtin://image");
      const saveImage = gf(gf(img, "values"), "save-image");

      return runtime.pauseStack((restarter) =>
        foreignRt.runThunk(() => {
          foreignRt.safeCall(
            () => {
              saveImage.app(ans.val, "/Users/ari/git/pyret-autograder/test.png");
              console.log("saved!");
            },
            (_) => restarter.resume(runtime.makeNumber(0)),
            "get-module-result-answer",
          );
        }, () => {})
      );

      // return runtime.pauseStack((restarter) => {
      //   const c = canvas.createCanvas(ans.val.width, ans.val.height);
      //   const ctx = c.getContext("2d");
      //   ans.val.render(ctx);
      //   const buf = c.toBuffer("image/png");
      //   fs.writeFile("./test.png", buf, () => restarter.resume(ans));
      // });
    }

    return runtime.makeModuleReturn({
      "get-module-result-answer":
        runtime.makeFunction(getModuleResultAnswer, "get-module-result-answer"),
    }, {});
  },
})
