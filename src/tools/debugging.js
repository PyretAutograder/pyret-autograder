/** @satisfies {PyretModule} */
({
  requires: [],
  provides: {
    values: {
      "wait-for-debugger": ["arrow", [], "Nothing"],
      "print-raw": ["arrow", ["Any"], "Nothing"],
      "print-json": ["arrow", ["String"], "Nothing"],
    },
  },
  nativeRequires: ["inspector"],
  /**
   * @param {import("node:inspector")} inspector
   */
  theModule: function (runtime, _namespace, _url, inspector) {
    function waitForDebugger() {
      runtime.checkArity(0, arguments, "wait-for-debugger", false);
      inspector.waitForDebugger();
      return runtime.nothing;
    }

    function printRaw(/** @type {any} */ val) {
      runtime.checkArity(1, arguments, "print-raw", false);
      runtime.console.dir(val, { depth: 2 });
      // debugger;
      return runtime.nothing;
    }

    function printJson(/** @type {string} */ str) {
      runtime.checkArity(1, arguments, "print-json", false);
      runtime.checkString(str);
      runtime.console.dir(JSON.parse(str), { depth: null });

      return runtime.nothing;
    }

    return runtime.makeModuleReturn({
      "wait-for-debugger": runtime.makeFunction(waitForDebugger, "wait-for-debugger"),
      "print-raw": runtime.makeFunction(printRaw, "print-raw"),
      "print-json": runtime.makeFunction(printJson, "print-json"),
    }, {});
  }
})
