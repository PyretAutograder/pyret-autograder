/** @satisfies {PyretModule} */
({
  requires: [],
  provides: {
    values: {
      "wait-for-debugger": ["arrow", [], "Nothing"],
      "print-raw": ["arrow", ["Any"], "Nothing"],
      "print-json": ["arrow", ["String"], "Nothing"],
      "print-module-result": ["arrow", ["Any"], "Nothing"],
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

    /**
     * @param {typeof console} console
     * @param {string} base
     * @param {Record<string, any>} obj
     * @param {Record<string, any>} execRt
     */
    function printPotentiallyPyret(console, base, obj, execRt) {
      for (const [key, val] of Object.entries(obj.dict)) {
        console.log(base + key);
        // debugger;
        console.dir({
          isNumber: execRt.isNumber(val),
          isBoolean: execRt.isBoolean(val),
          isNothing: execRt.isNothing(val),
          isFunction: execRt.isFunction(val),
          isMethod: execRt.isMethod(val),
          isString: execRt.isString(val),
          isOpaque: execRt.isOpaque(val),
          isArray: Array.isArray(val),
          isTuple: execRt.isTuple(val),
          isRef: execRt.isRef(val),
          isObject: execRt.isObject(val),
          val
        }, { depth: 1 });
        if (execRt.isObject(val)) {
          console.dir([base + key, val], { depth: 1 });
          // printModuleResult(console, base + key + ".", val, execRt);
        } else if (execRt.isPyretVal(val)) {
          console.dir([base + key, execRt.toRepr(val)]);
        } else if (runtime.isPyretVal(val)) {
          console.dir([base + key + "[rt]", runtime.toRepr(val)]);
        } else {
          console.dir([base + key, val], { depth: 1 });
        }
      }
    }

    // we can't just print this normally since it references different objects
    // than the current runtime
    function printModuleResult(/** @type {any} */ mr) {
      runtime.checkArity(1, arguments, "print-module-result", false);
      runtime.checkOpaque(mr);

      const execRt = mr.val.runtime;
      const result = mr.val.result;
      const stats = result.stats;
      // runtime.console.dir({ stats, result: execRt.toRepr(result.result) });
      runtime.console.dir({ stats,result: result.result });

      // printPotentiallyPyret(runtime.console, "", result.result, execRt);
      runtime.console.dir(execRt.toRepr(result.result.dict.checks))


      return runtime.nothing;
    }

    return runtime.makeModuleReturn({
      "wait-for-debugger": runtime.makeFunction(waitForDebugger, "wait-for-debugger"),
      "print-raw": runtime.makeFunction(printRaw, "print-raw"),
      "print-json": runtime.makeFunction(printJson, "print-json"),
      "print-module-result": runtime.makeFunction(printModuleResult, "print-module-result"),
    }, {});
  }
})
