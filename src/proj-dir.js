// prettier-ignore
({
  requires: [],
  provides: {
    values: {
      "get-proj-dir": ["arrow", [], "String"],
    },
  },
  nativeRequires: ["path"],
  theModule: (RUNTIME, NAMESPACE, uri, path) => {
    function getProjDir() {
      const stripped = uri.replace("jsfile://", "");
      const dir = path.join(path.dirname(stripped), "..");
      const resolved = path.resolve(dir);
      return RUNTIME.makeString(resolved);
    }

    return RUNTIME.makeModuleReturn(
      {
        "get-proj-dir": RUNTIME.makeFunction(getProjDir, "get-proj-dir"),
      },
      {},
    );
  },
})
