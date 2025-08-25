/** @satisfies {PyretModule} */
({
  requires: [
    { "import-type": "builtin", name: "error-display" },
    { "import-type": "builtin", name: "srcloc" },
  ],
  provides: {},
  nativeRequires: [],
  theModule: function (runtime, _namespace, _uri, errDisplay, srcloc) {
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
     * @param {PyretRuntime} rt
     */
    function rtHelpers(rt) {
      const gf = rt.getField;
      const gmf = (/** @type {any} */ mod, /** @type {string} */ field) => 
        gf(gf(mod, "values"), field)
      return [gf, gmf];
    }

    /**
     * @param {PyretRuntime} foreignRt
     * @param {any} foreignSrcloc
     */
    function translateSrcloc(foreignRt, foreignSrcloc) {
      const [ gf, gmf ] = rtHelpers(runtime);
      const [ fgf, fgmf ] = rtHelpers(foreignRt);
      const srclocM = getMod(foreignRt, "builtin://srcloc");

      return foreignRt.ffi.cases(fgmf(srclocM, "is-Srcloc"), "Srcloc", foreignSrcloc, {
        builtin: (moduleName) => gmf(srcloc, "builtin").app(moduleName),
        srcloc: (source, sline, scol, schar, eline, ecol, echar) =>
          gmf(srcloc, "srcloc").app(source, sline, scol, schar, eline, ecol, echar),
      });
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
      getMod,
      rtHelpers,
      translateSrcloc,
      translateErrorDisplay,
    });
  },
})
