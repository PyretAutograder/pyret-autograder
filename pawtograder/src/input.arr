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

import json as J
import string-dict as SD
import pathlib as Path
import npm("pyret-autograder", "main.arr") as A
import mk-feedbot from file("./graders/feedbot.arr")
import mk-program-inspector from file("./graders/program-inspector.arr")
import mk-style from file("./graders/style.arr")
import mk-docchk from file("./graders/docchk.arr")


provide:
  process-spec,
  convert-grader as _convert-grader
end

# none of the validation in this file is intended to be particuluarly helpful,
# the zod schema in lib/schema.ts should be used to validate the data with nicer
# messages

fun expect-obj(json :: J.JSON) -> SD.StringDict<J.JSON>:
  cases (J.JSON) json:
  | j-obj(sd) => sd
  | else =>
    spy: json end
    raise("Expected an object")
  end
end

fun expect-arr(json :: J.JSON) -> List<J.JSON>:
  cases (J.JSON) json:
  | j-arr(l) => l
  | else =>
    spy: json end
    raise("Expected an array")
  end
end

fun expect-str(json :: J.JSON) -> String:
  cases (J.JSON) json:
  | j-str(s) => s
  | else =>
    spy: json end
    raise("Expected a string")
  end
end

fun expect-num(json :: J.JSON) -> Number:
  cases (J.JSON) json:
  | j-num(n) => n
  | else =>
    spy: json end
    raise("Expected a number")
  end
end

fun expect-bool(json :: J.JSON) -> Boolean:
  cases (J.JSON) json:
  | j-bool(b) => b
  | else =>
    spy: json end
    raise("Expected a boolean")
  end
end

fun convert-grader(
  solution-dir :: String,
  submission-dir :: String,
  default-entry :: Option<String>,
  id :: String,
  grader :: SD.StringDict<J.JSON>
) -> A.Grader<Any, Any, Any> block: # TODO: these should be existentials
  deps = grader.get("deps")
               .and-then(expect-arr)
               .or-else([list:])
               .map(expect-str)

  entry-opt = grader.get("entry")
                    .and-then(expect-str)
                    .or-else(default-entry)

  # invariant not enforced by schema:
  when (is-none(entry-opt)):
    raise(
      "INVALID CONFIG: Grader " + id +
      " does not specify an `entry`point and no `default_entry` provided"
    )
  end

  entry = Path.resolve(Path.join(submission-dir, entry-opt.value))

  typ = grader.get-value("type") ^ expect-str

  ask block:
    | typ == "well-formed" then:
      A.mk-well-formed(id, deps, entry)
    | typ == "training-wheels" then:
      config = grader.get-value("config") ^ expect-obj
      top-level-only = config.get-value("top_level_only") ^ expect-bool
      A.mk-training-wheels(id, deps, entry, top-level-only)
    | typ == "function-defined" then:
      config = grader.get-value("config") ^ expect-obj
      fn-name = config.get-value("function") ^ expect-str
      arity = config.get-value("arity") ^ expect-num
      A.mk-fn-def(id, deps, entry, fn-name, arity)
    | typ == "constant-defined" then:
      config = grader.get-value("config") ^ expect-obj
      const-name = config.get-value("constant") ^ expect-str
      A.mk-const-def(id, deps, entry, const-name)
    | typ == "test-diversity" then:
      config = grader.get-value("config") ^ expect-obj
      fn = config.get-value("function") ^ expect-str
      min-in = config.get-value("min_in") ^ expect-num
      min-out = config.get-value("min_out") ^ expect-num
      A.mk-test-diversity(id, deps, entry, fn, min-in, min-out)
    | (typ == "wheat") or (typ == "chaff") then:
      config = grader.get-value("config") ^ expect-obj
      _path = config.get-value("path") ^ expect-str
      path = Path.resolve(Path.join(solution-dir, _path))
      func = config.get-value("function") ^ expect-str
      points = grader.get("points").and-then(expect-num).or-else(0)
      if typ == "wheat":
        A.mk-wheat(id, deps, entry, path, func, points)
      else:
        A.mk-chaff(id, deps, entry, path, func, points)
      end
    | typ == "functional" then:
      config = grader.get-value("config") ^ expect-obj
      _path = config.get-value("path") ^ expect-str
      path = Path.resolve(Path.join(solution-dir, _path))
      check-name = config.get-value("check") ^ expect-str
      func = config.get("function").and-then(expect-str)
      points = grader.get("points").and-then(expect-num).or-else(0)
      A.mk-functional(id, deps, entry, path, check-name, points, func)
    | typ == "self-test" then:
      config = grader.get-value("config") ^ expect-obj
      func = config.get-value("function") ^ expect-str
      points = grader.get("points").and-then(expect-num).or-else(0)
      A.mk-self-test(id, deps, entry, func, points)
    | typ == "feedbot" then:
      config = grader.get-value("config") ^ expect-obj
      func = config.get-value("function") ^ expect-str
      model = config.get("model").and-then(expect-str)
      provider = config.get("provider").and-then(expect-str)
      temperature = config.get("temperature").and-then(expect-num).or-else(1)
      account = config.get("account").and-then(expect-str)
      max-tokens = config.get("max_tokens").and-then(expect-num).or-else(5000)
      mk-feedbot(id, deps, entry, func, model, provider, temperature, account, max-tokens)
    | typ == "program-inspector" then:
      mk-program-inspector(id, deps, entry)
    | typ == "style" then:
      points = grader.get("points").and-then(expect-num).or-else(0)
      mk-style(id, deps, entry, entry-opt.value, points)
    | typ == "docchk" then:
      points = grader.get("points").and-then(expect-num).or-else(0)
      config = grader.get-value("config") ^ expect-obj
      fn-name = config.get-value("function") ^ expect-str
      mk-docchk(id, deps, entry, fn-name, points)
    | typ == "image-artifact" then:
      out = grader.get-value("out") ^ expect-str
      config = grader.get-value("config") ^ expect-obj
      _generator_ = config.get-value("generator") ^ expect-str
      generator_ = Path.resolve(Path.join(solution-dir, _generator_))
      name = config.get-value("name") ^ expect-str
      A.mk-image-artifact(id, deps, entry, generator_, out, name)
    | otherwise: raise("INVALID CONFIG: unknown grader type " + typ)
  end
end

fun process-spec(spec :: J.JSON) -> List<A.Grader>:
  doc: ```
       Processes a grading spec which should follow satisfy the Spec type found
       in ../lib/schema.ts
       ```
  toplevel = expect-obj(spec)

  solution-dir = toplevel.get-value("solution_dir") ^ expect-str
  submission-dir = toplevel.get-value("submission_dir") ^ expect-str
  config = toplevel.get-value("config") ^ expect-obj

  default-entry = config.get("default_entry").and-then(expect-str) # optional
  graders = config.get-value("graders") ^ expect-arr

  for map(arr from graders):
    lst = expect-arr(arr)
    id = lst.get(0) ^ expect-str
    grader = lst.get(1) ^ expect-obj
    convert-grader(solution-dir, submission-dir, default-entry, id, grader)
  end
end

