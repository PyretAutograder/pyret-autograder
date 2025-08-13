/*
  Copyright (C) 2025 ironmoon <me@ironmoon.dev>

  This file is part of pyret-autograder.

  pyret-autograder is free software: you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License as published by the
  Free Software Foundation, either version 3 of the License, or (at your option)
  any later version.

  pyret-autograder is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
  for more details.

  You should have received a copy of the GNU Lesser General Public License
  with pyret-autograder. If not, see <http://www.gnu.org/licenses/>.
*/
/** @satisfies {PyretModule} */
({
  requires: [],
  provides: {
    values: {
      "get-stdin": ["arrow", [], "String"],
      "send-final": ["arrow", ["String"], "Nothing"],
    },
  },
  nativeRequires: ["fs/promises"],
  /**
   * @param {import('fs/promises')} fs
   */
  theModule: function (runtime, _namespace, _url, fs) {
    "use strict"

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

    /**
      * @param {string} s
      */
    function sendFinal(s) {
      runtime.checkArity(1, arguments, "send-final", false);
      runtime.checkString(s);

      const fd = (() => {
        const v = process.env.PA_RESULT_FD;
        return (v != null && /^\d+$/.test(v)) ? Number(v) : 3;
      })();

      return runtime.await((async () => {
        const line = s.endsWith("\n") ? s : s + "\n";
        // @ts-ignore: type definitions are wrong
        await fs.writeFile(fd, line);
        return runtime.nothing;
      })());
    }

    return runtime.makeModuleReturn({
      "get-stdin": runtime.makeFunction(getStdin, "get-stdin"),
      "send-final": runtime.makeFunction(sendFinal, "send-final"),
    }, {});
  }
})
