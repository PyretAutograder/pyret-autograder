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
      "escape-typesystem": ["forall", ["A", "B"], ["arrow", [["tid", "A"]], ["tid", "B"]]]
    },
  },
  nativeRequires: [],
  theModule: function (runtime, _namespace, _uri) {
    "use strict";
    function escapeTypesystem(/** @type {any} */ x) {
      runtime.checkArity(1, arguments, "escape-typesystem", false);
      return x;
    }

    return runtime.makeModuleReturn({
      "escape-typesystem": runtime.makeFunction(escapeTypesystem, "escape-typesystem")
    }, {});
  },
})
