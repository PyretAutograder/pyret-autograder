/** @satisfies {PyretModule} */
/*
 * This deals with the module return value from the Pyret runtime.
 *
 * Due to the representation of pyret values, we cannot pass values resulting from
 * the repl to the host without first serializing them. The `load-lib` module is
 * intended to do this, but doesn't provide very rich error displaying, nor give
 * complete raw information about the checks that were run.
 *
 * All errors will be rendered
 */
({
  requires: [
    {"import-type": "dependency", protocol: "js-file", args: ["./bridge"]},
  ],
  provides: {
    values: {
      "extract-check-results": ["arrow", ["Any"], ["List", "Any"]],
    },
  },
  nativeRequires: ["pyret-base/js/exn-stack-parser"],
  theModule: function (runtime, _namespace, _uri, bridge, stackLib) {
    "use strict";
    const EXIT_SUCCESS = 0;
    const EXIT_ERROR = 1;
    const EXIT_ERROR_RENDERING_ERROR = 2;
    const EXIT_ERROR_DISPLAYING_ERROR = 3;
    const EXIT_ERROR_CHECK_FAILURES = 4;
    const EXIT_ERROR_JS = 5;
    const EXIT_ERROR_UNKNOWN = 6;

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
    function getModuleResultChecks(mr) {
      checkSuccess(mr, "checks");
      const checks = mr.val.runtime.getField(mr.val.result.result, "checks");
      if (mr.val.runtime.ffi.isList(checks)) {
        return checks;
      } else {
        return mr.val.runtime.ffi.makeList([]);
      }
    }

    /**
     * @param {ModuleReturn} mr
     */
    function extractCheckResults(mr) {
      runtime.checkArity(1, arguments, "extract-check-results", false);
      runtime.checkOpaque(/** @type {any} */ (mr));
      return runtime.pauseStack(function (restarter) {
        const execRt = mr.val.runtime;
        const gf = execRt.getField;
        const checkerMod = execRt.modules["builtin://checker"];
        const checker = gf(checkerMod, "provide-plus-types");
        const checkerVals = gf(checker, "values");
        const renderCheckResults = gf(checkerVals, "render-check-results-stack");
        const realm = runtime.getField(mr.val.realm, "realm").val;
        const getStack = execRt.makeFunction((/** @type {any} */ err) => {
          const pyretStack = stackLib.convertExceptionToPyretStackTrace(err.val, realm);
          const locArray = pyretStack.map(execRt.makeSrcloc);
          const locList = execRt.ffi.makeList(locArray);
          return locList;
        }, "get-stack");

        const blockResults = getModuleResultChecks(mr);

        // const results = [];
        // for (const blockResult of execRt.ffi.toArray(blockResults)) {
        //   const name = gf(blockResult, "name");
        //   const loc = gf(blockResult, "loc");
        //   const kwCheck = gf(blockResult, "keyword-check");
        //   const testRes = gf(blockResult, "test-results");
        //   const maybeError = gf(blockResult, "maybe-err");
        //
        //   const bridged = {
        //     name: name,
        //     loc: bridge.translateSrcloc(execRt, loc),
        //
        //   }
        //
        //   results.push(bridged)
        //
        //
        //   console.log("Block result:");
        //   console.dir(blockResult)
        //   console.dir(execRt.toRepr(blockResult));
        // }




        // edBridge.translateErrorDisplay(execRt, ...)

        execRt.runThunk(
          function() {return renderCheckResults.app(blockResults, getStack, "json")},
          function (/** @type {any} */ renderedCheckResults) {
            runtime.console.dir(renderedCheckResults)
            const resumeWith = {
              message: "Unknown error!",
              "exit-code": EXIT_ERROR_UNKNOWN,
            };

            if (execRt.isSuccessResult(renderedCheckResults)) {
              resumeWith.message = execRt.unwrap(
                execRt.getField(renderedCheckResults.result, "message")
              );
              const errs = execRt.getField(renderedCheckResults.result, "errored");
              const failed = execRt.getField(renderedCheckResults.result, "failed");
              if (errs !== 0 || failed !== 0) {
                resumeWith["exit-code"] = EXIT_ERROR_CHECK_FAILURES;
              } else {
                resumeWith["exit-code"] = EXIT_SUCCESS;
              }
            } else if (execRt.isFailureResult(renderedCheckResults)) {
              console.error(renderedCheckResults.exn);
              resumeWith.message = "There was an exception while formatting the check results";
              resumeWith["exit-code"] = EXIT_ERROR_RENDERING_ERROR;
            }

            restarter.resume(
              runtime.makeObject({
                message: runtime.makeString(resumeWith.message),
                "exit-code": runtime.makeNumber(resumeWith["exit-code"]),
              })
            );
          }
        );
      });
    }
    return runtime.makeModuleReturn({
      "extract-check-results": runtime.makeFunction(extractCheckResults, "extract-check-results"),
    }, {});
  },
})
