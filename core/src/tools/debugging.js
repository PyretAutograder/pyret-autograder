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
      "wait-for-debugger": ["arrow", [], "Nothing"],
      "print-raw": ["arrow", ["Any"], "Nothing"],
      "print-json": ["arrow", ["String"], "Nothing"],
    },
  },
  nativeRequires: ["inspector"],
  /**
   * @param {import("node:inspector")} inspector
   */
  theModule: function (runtime, _namespace, _url, inspector) {
    function waitForDebugger() {
      runtime.checkArity(0, arguments, "wait-for-debugger", false);
      inspector.waitForDebugger();
      return runtime.nothing;
    }

    function printRaw(/** @type {any} */ val) {
      runtime.checkArity(1, arguments, "print-raw", false);
      runtime.console.dir(val, { depth: 2 });
      // debugger;
      return runtime.nothing;
    }

    function printJson(/** @type {string} */ str) {
      runtime.checkArity(1, arguments, "print-json", false);
      runtime.checkString(str);
      runtime.console.dir(JSON.parse(str), { depth: null });

      return runtime.nothing;
    }

    return runtime.makeModuleReturn({
      "wait-for-debugger": runtime.makeFunction(waitForDebugger, "wait-for-debugger"),
      "print-raw": runtime.makeFunction(printRaw, "print-raw"),
      "print-json": runtime.makeFunction(printJson, "print-json"),
    }, {});
  }
})
