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
      "get-proj-dir": ["arrow", [], "String"],
    },
  },
  nativeRequires: ["path"],
  theModule: (runtime, _, uri, /** @type {import('node:path')} */ path) => {
    "use strict";
    function getProjDir() {
      runtime.checkArity(0, arguments, "get-proj-dir", false);
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
