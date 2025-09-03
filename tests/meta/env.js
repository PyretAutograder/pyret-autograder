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
      "override-env": ["arrow", ["tany"], "Nothing"],
    },
  },
  nativeRequires: [],
  theModule: (runtime, _, __) => {
    "use strict";
    function overrideEnv(/** @type {*} */ override) {
      runtime.checkArity(1, arguments, "override-env", false);
      runtime.checkObject(override);

      Object.assign(process.env, override.dict);
      
      return runtime.nothing;
    }

    return runtime.makeModuleReturn({
      "override-env": runtime.makeFunction(overrideEnv, "get-proj-dir"),
    }, {});
  },
})
