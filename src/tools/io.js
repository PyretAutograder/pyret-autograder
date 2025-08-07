/** @satisfies {PyretModule} */
({
  requires: [],
  provides: {
    values: {
      "get-stdin": ["arrow", [], "String"],
    },
  },
  nativeRequires: [],
  theModule: function (runtime, _namespace, _url) {
    let input = "";
    let eof = false;

    runtime.stdin.setEncoding("utf8");
    runtime.stdin.on("data", (chunk) => (input += chunk));
    runtime.stdin.on("end", () => (eof = true));

    function getStdin() {
      runtime.checkArity(0, arguments, "get-stdin", false);
      if (!eof) {
        return runtime.pauseStack(async (restarter) => {
          runtime.stdin.on("end", () => {
            restarter.resume(runtime.makeString(input));
          });
        });
      }

      return runtime.makeString(input);
    }

    return runtime.makeModuleReturn({
      "get-stdin": runtime.makeFunction(getStdin, "get-stdin"),
    }, {});
  }
})
