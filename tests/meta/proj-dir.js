// prettier-ignore
({
  requires: [],
  provides: {
    values: {
      "get-proj-dir": ["arrow", [], "String"],
    },
  },
  nativeRequires: ["path"],
  theModule: (runtime, _, uri, path) => {
    function getProjDir() {
      runtime.checkArity(0, arguments, false);
      const stripped = uri.replace("jsfile://", "");
      const proj = path.join(path.dirname(stripped), "../..");
      const resolved = path.resolve(proj);
      return runtime.makeString(resolved);
    }

    return runtime.makeModuleReturn({
      "get-proj-dir": runtime.makeFunction(getProjDir, "get-proj-dir"),
    }, {});
  },
})
