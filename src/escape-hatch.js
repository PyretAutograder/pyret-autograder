// prettier-ignore
({
  requires: [],
  provides: {
    values: {
      "escape-typesystem": ["forall", ["A", "B"], ["arrow", [["tid", "A"]], ["tid", "B"]]]
    },
  },
  nativeRequires: [],
  theModule: function (runtime, _, _) {
    function escapeTypesystem(x) {
      runtime.checkArity(1, arguments, false);
      return x;
    }

    return runtime.makeModuleReturn({
      "escape-typesystem": runtime.makeFunction(escapeTypesystem, "escape-typesystem")
    }, {});
  },
})
