/** @satisfies {PyretModule} */
({
  requires: [{ "import-type": "builtin", name: "error-display" }],
  provides: {},
  nativeRequires: [],
  theModule: function (runtime, _namespace, _uri, errDisplay) {
    "use strict";

    /**
     * @param {PyretRuntime} foreignRt
     * @param {string} modName
     */
    function getMod(foreignRt, modName) {
      const mod = foreignRt.modules[modName];
      if (mod == null) {
        runtime.ffi.throwMessageException(`Cannot find foreign module ${modName}`);
      }
      return foreignRt.getField(mod, "provide-plus-types");
    }

    /**
     * @param {PyretRuntime} foreignRt
     * @param {any} srcloc
     */
    function translateSrcloc(foreignRt, srcloc) {
      const gf = foreignRt.getField;
      const srclocM = getMod(foreignRt, "builtin://srcloc");

      return foreignRt.ffi.cases(gf(gf(srclocM, "values"), "is-Srcloc"), "Srcloc", srcloc, {

      });

      console.dir(srclocM, {depth: 3})
      runtime.ffi.throwMessageException("TODO");

    }

    /**
     * @param {PyretRuntime} foreignRt
     * @param {any} errDisp
     */
    function translateErrorDisplay(foreignRt, errDisp) {
      const errDispM = getMod(foreignRt, "builtins://error-display");

      console.dir(errDispM);
      runtime.ffi.throwMessageException("TODO");
    }


    return runtime.makeJSModuleReturn({
      translateSrcloc,
      translateErrorDisplay,
    });
  },
})
