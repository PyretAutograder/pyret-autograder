#|
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
|#

include file("../src/input.arr")
include json
include string-dict
import npm("pyret-autograder", "main.arr") as A

fun is-Grader(grader :: A.Grader) -> Boolean:
  true
end

check "convert-grader":
  solution-dir = "/path/to/solution"
  submission-dir = "/path/to/submission"
  default-entry = some("entry.arr")
  id = "some-id"
  convert = lam(x):
    dict = to-json(x).dict
    _convert-grader(solution-dir, submission-dir, default-entry, id, dict)
  end

  deps = [list: "id-1", "id-2"]

  # TODO: can we check a contract here?
  convert([string-dict:
            "deps", deps,
            "type", "well-formed"]) satisfies is-Grader
  convert([string-dict:
            "deps", deps,
            "type", "training-wheels",
            "config", [string-dict:
              "top_level_only", true]]) satisfies is-Grader
  convert([string-dict:
            "deps", deps,
            "type", "function-defined",
            "config", [string-dict:
              "function", "foo",
              "arity", 3]]) satisfies is-Grader
  convert([string-dict:
            "deps", deps,
            "type", "constant-defined",
            "config", [string-dict:
              "constant", "foo"]]) satisfies is-Grader
  convert([string-dict:
            "deps", deps,
            "type", "test-diversity",
            "config", [string-dict:
              "function", "foo",
              "min_in", 3,
              "min_out", 2]]) satisfies is-Grader
  convert([string-dict:
            "deps", deps,
            "type", "wheat",
            "config", [string-dict:
              "path", "impl.arr",
              "function", "foo",
              "points", 1]]) satisfies is-Grader
  convert([string-dict:
            "deps", deps,
            "type", "chaff",
            "config", [string-dict:
              "path", "impl.arr",
              "function", "foo",
              "points", 1]]) satisfies is-Grader
  convert([string-dict:
            "deps", deps,
            "type", "functional",
            "config", [string-dict:
              "path", "checks.arr",
              "check", "foo-correctness",
              "function", "foo",
              "points", 1]]) satisfies is-Grader
  convert([string-dict:
            "deps", deps,
            "type", "self-test",
            "config", [string-dict:
              "function", "foo",
              "points", 1]]) satisfies is-Grader
  convert([string-dict:
            "deps", deps,
            "type", "feedbot",
            "config", [string-dict:
              "function", "foo",
              "model", "gpt-77",
              "provider", "megacorp",
              "temperature", ~0.5,
              "account", "Aoun",
              "max_tokens", 100000]]) satisfies is-Grader
  convert([string-dict:
            "deps", deps,
            "type", "program-inspector"]) satisfies is-Grader
  convert([string-dict:
            "deps", deps,
            "type", "image-artifact",
            "out", "artifact.png",
            "config", [string-dict:
              "generator", "problem1.arr",
              "name", "Problem 1"]]) satisfies is-Grader
  convert([string-dict:
            "deps", deps,
            "type", "style",
            "config", [string-dict:]]) satisfies is-Grader
end

