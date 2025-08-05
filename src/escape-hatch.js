/** @satisfies {PyretModule} */
({
  requires: [],
  provides: {
    values: {
      "escape-typesystem": ["forall", ["A", "B"], ["arrow", [["tid", "A"]], ["tid", "B"]]]
    },
  },
  nativeRequires: [],
  theModule: function (runtime, _namespace, _uri) {
    function escapeTypesystem(/** @type {any} */ x) {
      runtime.checkArity(1, arguments, "escape-typesystem", false);
      return x;
    }

    return runtime.makeModuleReturn({
      "escape-typesystem": runtime.makeFunction(escapeTypesystem, "escape-typesystem")
    }, {});
  },
})
