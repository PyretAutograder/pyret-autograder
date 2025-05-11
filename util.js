({
  nativeRequires: ["node:child_process"],
  requires: [],
  provides: {
    values: {
      exec: [
        "arrow",
        ["String", ["List", "String"]],
        ["tuple", ["String", "String"]],
      ],
    },
  },
  theModule: function (runtime, _namespace, _uri, process) {
    function exec(command, args) {
      runtime.checkArgsInternal2(
        "utils",
        "exec",
        command,
        runtime.String,
        args,
        runtime.List
      );
      const argsArray = runtime.ffi.toArray(args);
      return runtime.pauseStack((restarter) => {
        process.execFile(command, argsArray, {}, (_error, stdout, stderr) => {
          const ret = runtime.makeTuple([String(stdout), String(stderr)]);
          restarter.resume(ret);
        });
      });
    }
    return runtime.makeModuleReturn(
      {
        exec: runtime.makeFunction(exec),
      },
      {}
    );
  },
});
