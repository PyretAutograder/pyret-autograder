#|
  Copyright (C) 2025 ironmoon <me@ironmoon.dev>

  This file is part of pyret-autograder-gradescope.

  pyret-autograder-gradescope is free software: you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation, either version 3 of the License,
  or (at your option) any later version.

  pyret-autograder-gradescope is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
  General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  with pyret-autograder-gradescope. If not, see <http://www.gnu.org/licenses/>.
|#
import lists as L
import json as J
import string-dict as SD
import ast as AST
import npm("pyret-autograder", "main.arr") as A

include from A:
  module grading-helpers
end

provide:
  data GradescopeFeedback,
  data GradescopeFormat,
  data GradescopeVisibility,
  data GradescopeTest,
  data GradescopeTestStatus,
  data GradescopeLeaderboard,
  data GradescopeLeaderboardOrder,
  prepare-for-gradescope
end

fun add(sd :: SD.MutableStringDict, key :: String, val, trans):
  if (is-Option(val)) block:
    cases (Option) val:
      | none => nothing
      | some(v) => sd.set-now(key, trans(v))
    end
  else:
    sd.set-now(key, trans(val))
  end
end

fun map-json(trans):
  lam(lst):
    L.map(trans, lst) ^ J.j-arr
  end
end

fun num-to-json(num :: Number) -> J.JSON:
  if num-is-fixnum(num) or num-is-roughnum(num):
    J.to-json(num)
  else:
    J.to-json(num-to-roughnum(num))
  end
end

data GradescopeFeedback:
  gradescope-feedback(
    score :: Option<Number>,
    execution-time :: Option<Number>,
    output :: Option<String>,
    output-format :: Option<GradescopeFormat>,
    test-output-format :: Option<GradescopeFormat>,
    test-name-format :: Option<GradescopeFormat>,
    visibility :: Option<GradescopeVisibility>,
    stdout-visibility :: Option<GradescopeVisibility>,
    extra-data :: Option<Any>,
    tests :: List<GradescopeTest>,
    leaderboard :: List<GradescopeLeaderboard>) with:
  method to-json(self) -> J.JSON block:
    sd = [SD.mutable-string-dict:]
    shadow add = add(sd, _, _, _)
    add("score", self.score, num-to-json)
    add("execution_time", self.execution-time, num-to-json)
    add("output", self.output, J.to-json)
    add("output_format", self.output-format, _.to-json())
    add("visibility", self.visibility, _.to-json())
    add("stdout_visibility", self.stdout-visibility, _.to-json())
    add("extra_data", self.extra-data, J.to-json)
    add("tests", self.tests, map-json(_.to-json()))
    add("leaderboard", self.leaderboard, map-json(_.to-json()))
    J.j-obj(sd.freeze())
  end
end

data GradescopeFormat:
  | text
  | html
  | simple-format
  | md
  | ansi
sharing:
  method to-json(self) -> J.JSON block:
    cases (GradescopeFormat) self:
      | text => J.j-str("text")
      | html => J.j-str("html")
      | simple-format => J.j-str("simple_format")
      | md => J.j-str("md")
      | ansi => J.j-str("ansi")
    end
  end
end

data GradescopeVisibility:
  | hidden
  | after-due-date
  | after-published
  | visible
sharing:
  method to-json(self) -> J.JSON block:
    cases (GradescopeVisibility) self:
      | hidden => J.j-str("hidden")
      | after-due-date => J.j-str("after_due_date")
      | after-published => J.j-str("after_published")
      | visible => J.j-str("visible")
    end
  end
end

data GradescopeTest:
  gradescope-test(
    score :: Option<Number>,
    max-score :: Option<Number>,
    status :: Option<GradescopeTestStatus>,
    name :: Option<String>,
    name-format :: Option<GradescopeFormat>,
    number :: Option<String>,
    output :: Option<String>,
    output-format :: Option<GradescopeFormat>,
    tags :: List<String>,
    visibility :: Option<GradescopeVisibility>,
    extra-data :: Option<Any>) with:
  method to-json(self) -> J.JSON block:
    sd = [SD.mutable-string-dict:]
    shadow add = add(sd, _, _, _)
    add("score", self.score, num-to-json)
    add("max_score", self.max-score, num-to-json)
    add("status", self.status, _.to-json())
    add("name", self.name, J.to-json)
    add("name_format", self.name-format, _.to-json())
    add("number", self.number, J.to-json)
    add("output", self.output, J.to-json)
    add("output_format", self.output-format, _.to-json())
    add("tags", self.tags, J.to-json)
    add("visibility", self.visibility, _.to-json())
    add("extra_data", self.extra-data, J.to-json)
    J.j-obj(sd.freeze())
  end
end

data GradescopeTestStatus:
  | passed
  | failed
sharing:
  method to-json(self) -> J.JSON block:
    cases (GradescopeTestStatus) self:
      | passed => J.j-str("passed")
      | failed => J.j-str("failed")
    end
  end
end

data GradescopeLeaderboard:
  gradescope-leaderboard(
    name :: String,
    value :: Any,
    _order :: Option<GradescopeLeaderboardOrder>) with:
  method to-json(self) -> J.JSON block:
    sd = [SD.mutable-string-dict:]
    shadow add = add(sd, _, _, _)
    add("name", self.name, J.to-json)
    add("value", self.value, J.to-json)
    add("order", self._order, _.to-json())
    J.j-obj(sd.freeze())
  end
end

data GradescopeLeaderboardOrder:
  | desc
  | asc
sharing:
  method to-json(self) -> J.JSON block:
    cases (GradescopeLeaderboardOrder) self:
      | desc => J.j-str("desc")
      | asc => J.j-str("asc")
    end
  end
end

fun aggregate-output-to-gradescope(output :: A.AggregateOutput) -> {GradescopeFormat; String}:
  cases (A.AggregateOutput) output:
    | output-text(content) => {text; content}
    | output-markdown(content) => {md; content}
    | output-ansi(content) => {ansi; content}
  end
end

fun prepare-for-gradescope(output :: A.GradingOutput) -> J.JSON block:
  flattened = grading-helpers.aggregate-to-flat(output.aggregated)
  {tests; score; max-score} = for fold(
    {acc-tests; acc-score; acc-max-score} as acc from [list:],
    {id; flat} from flattened
  ):
    cases (grading-helpers.FlatAggregateResult) flat:
      | flat-agg-test(name, max-score, score, go, so, part) =>
        # NOTE(owen): since Gradescope doesn't support instructor only output,
        # we create additional hidden dummy tests to show this info.
        shadow acc-tests = cases (Option) so:
          | some(shadow so) =>
            {sof; sos} = aggregate-output-to-gradescope(so)
            dummy-test = gradescope-test(
              none, none,
              some(passed),
              some("[Staff Only] " + name), none,
              none,
              some(sos), some(sof),
              [list: part],
              some(hidden),
              none
            )
            link(dummy-test, acc-tests)
          | none => acc-tests
        end

        {gof; gos} = aggregate-output-to-gradescope(go)
        test = gradescope-test(
          some(score), some(max-score),
          none, # TODO: consider if overriding status would be useful
          some(name), none,
          none,
          some(gof), some(gos),
          [list: part],
          some(visible),
          none
        )
        shadow acc-tests = link(test, acc-tests)
        shadow acc-score = acc-score + score
        shadow acc-max-score = acc-max-score + max-score
        {acc-tests; acc-score; acc-max-score}
      # TODO: support artifacts: upload, create dummy test with link
      | flat-agg-art(_, _, _, _) => acc
    end
  end
  ^ {({tests; score; max-score}): {tests.reverse(); score; max-score}}

  # We repeat the score here since Gradescope won't show a student's score when
  # there are hidden tests (which are used to display staff-only output).
  tl-output = "**Score**: " +
    num-to-string-digits(score) + "/" + num-to-string-digits(max-score)

  gradescope-feedback(
    none, none,
    some(tl-output),
    some(md),
    some(text),
    some(text),
    tests,
    some(visible),
    some(visible),
    none,
    tests,
    [list:]
  ).to-json()
end

