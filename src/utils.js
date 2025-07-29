// prettier-ignore
({
  requires: [],
  provides: {
    values: {
      "get-proj-dir": ["arrow", [], "String"],
      "pretty-print-json": ["arrow", ["String"], "Nothing"],
      "dangerously-escape-typesystem": ["forall", ["A", "B"], ["arrow", [["tid", "A"]], ["tid", "B"]]]
    },
  },
  nativeRequires: ["path"],
  theModule: (runtime, namespace, uri, path) => {
    function getProjDir() {
      const stripped = uri.replace("jsfile://", "");
      const dir = path.join(path.dirname(stripped), "..");
      const resolved = path.resolve(dir);
      return runtime.makeString(resolved);
    }

    function prettyPrintJSON(json) {
      runtime.checkArity(1, arguments, false);
      runtime.checkString(json);
      console.dir(JSON.parse(json), { depth: null, colors: true });
      return runtime.nothing;
    }

    function dangerouslyEscapeTypesystem(x) {
      runtime.checkArity(1, arguments, false);
      return x;
    }

    return runtime.makeModuleReturn(
      {
        "get-proj-dir": runtime.makeFunction(getProjDir, "get-proj-dir"),
        "pretty-print-json": runtime.makeFunction(prettyPrintJSON, "pretty-print-json"),
        "dangerously-escape-typesystem": runtime.makeFunction(
          dangerouslyEscapeTypesystem,
          "dangerously-escape-typesystem"
        )
      },
      {},
    );
  },
})
