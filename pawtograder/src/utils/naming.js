/*
  Copyright (C) 2025 ironmoon <me@ironmoon.dev>

  This file is part of pyret-autograder-pawtograder.

  pyret-autograder-pawtograder is free software: you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation, either version 3 of the License,
  or (at your option) any later version.

  pyret-autograder-pawtograder is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
  General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  with pyret-autograder-pawtograder. If not, see <http://www.gnu.org/licenses/>.
*/

/** @satisfies {PyretModule} */
({
  requires: [],
  provides: {
    values: {
      "is-kebab-case": ["arrow", ["String"], "Boolean"],
      "is-capital-kebab-case": ["arrow", ["String"], "Boolean"]
    },
  },
  nativeRequires: [],
  theModule: function (runtime, _namespace, _uri) {
    "use strict";

    /**
      * @param {string} name
      */
    function isKebabCase(name) {
      runtime.checkArity(1, arguments, "is-kebab-case", false);
      runtime.checkString(name);
      return /^[a-z0-9]+(-[a-z0-9]+)*$/.test(name);
    }

    /**
      * @param {string} name
      */
    function isCapitalKebabCase(name) {
      runtime.checkArity(1, arguments, "is-capital-kebab-case", false);
      runtime.checkString(name);
      return /^[A-Z0-9]+(-[A-Z0-9]+)*$/.test(name);
    }

    return runtime.makeModuleReturn({
      "is-kebab-case": runtime.makeFunction(isKebabCase, "is-kebab-case"),
      "is-capital-kebab-case": runtime.makeFunction(isCapitalKebabCase, "is-capital-kebab-case"),
    }, {});
  },
})
