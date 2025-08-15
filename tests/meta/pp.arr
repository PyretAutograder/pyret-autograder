#|
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
|#
include pprint
include file("../../src/grading.arr")
provide *

# DISCLAIMER: the following is LLM generated

comma-sep = str(",") + sbreak(1)
comma-only = str(",")

fun pp-multiline-string(s :: String):
  doc: ```
    Pretty-prints a multi-line string. Single-line strings are quoted normally,
    while multi-line strings are formatted as a list of quoted lines.
  ```
  lines = string-split-all(s, "\n")
  if lines.length() == 1:
    dquote(str(s))
  else:
    group(
      concat(lbrack,
        concat(nest(2,
          concat(hardline,
            separate(comma-sep,
              lines.map(lam(line): dquote(str(line)) end)))),
          concat(hardline, rbrack))))
  end
end

fun pp-aggregate-output(output :: AggregateOutput):
  doc: ```
    Pretty-prints an AggregateOutput value, formatting the content with proper
    indentation.
  ```
  cases (AggregateOutput) output:
    | output-text(content) =>
      group(concat(str("output-text:"),
        nest(2, concat(sbreak(1), pp-multiline-string(content)))))
    | output-markdown(content) =>
      group(concat(str("output-markdown:"),
        nest(2, concat(sbreak(1), pp-multiline-string(content)))))
    | output-ansi(content) =>
      group(concat(str("output-ansi:"),
        nest(2, concat(sbreak(1), pp-multiline-string(content)))))
  end
end

fun pp-option(opt :: Option<AggregateOutput>):
  doc: ```
    Pretty-prints an Option<AggregateOutput>, displaying 'none' or 'some(...)'
    with proper formatting.
  ```
  cases (Option) opt:
    | none => str("none")
    | some(v) =>
      group(
        concat(str("some("),
          concat(nest(2, concat(sbreak(0), pp-aggregate-output(v))),
            concat(sbreak(0), str(")")))))
  end
end

fun pp-option-string(opt :: Option<String>):
  doc: ```
    Pretty-prints an Option<String>, displaying 'none' or 'some(...)'
    with proper formatting.
  ```
  cases (Option) opt:
    | none => str("none")
    | some(v) =>
      group(
        concat(str("some("),
          concat(nest(2, concat(sbreak(0), dquote(str(v)))),
            concat(sbreak(0), str(")")))))
  end
end

fun pp-guard-outcome(outcome :: GuardOutcome):
  doc: ```
    Pretty-prints a GuardOutcome value with appropriate formatting for each
    variant.
  ```
  cases (GuardOutcome) outcome:
    | guard-passed => str("guard-passed")
    | guard-blocked(general-output, staff-output) =>
      group(
        soft-surround(2, 1,
          str("guard-blocked("),
          separate(comma-sep,
            [list:
              concat(str("general: "), pp-aggregate-output(general-output)),
              concat(str("staff: "), pp-option(staff-output))]),
          str(")")))
    | guard-skipped(id) =>
      concat(str("guard-skipped("), concat(str(tostring(id)), str(")")))
  end
end

fun pp-test-outcome(outcome :: TestOutcome):
  doc: ```
    Pretty-prints a TestOutcome value, formatting score and output fields.
  ```
  cases (TestOutcome) outcome:
    | test-ok(shadow score, general-output, staff-output) =>
      group(
        soft-surround(2, 1,
          str("test-ok("),
          separate(comma-sep,
            [list:
              concat(str("score: "), number(score)),
              concat(str("general: "), pp-aggregate-output(general-output)),
              concat(str("staff: "), pp-option(staff-output))]),
          str(")")))
    | test-skipped(id) =>
      concat(str("test-skipped("), concat(str(tostring(id)), str(")")))
  end
end

fun pp-artifact-outcome(outcome :: ArtifactOutcome):
  doc: ```
    Pretty-prints an ArtifactOutcome value with path and extra information.
  ```
  cases (ArtifactOutcome) outcome:
    | art-ok(path, extra) =>
      group(
        soft-surround(2, 1,
          str("art-ok("),
          separate(comma-sep,
            [list:
              dquote(str(path)),
              str(to-repr(extra))]),
          str(")")))
    | art-skipped(id) =>
      concat(str("art-skipped("), concat(str(tostring(id)), str(")")))
  end
end

fun pp-aggregate-result(result :: AggregateResult):
  doc: ```
    Pretty-prints an AggregateResult value, handling guards, tests, and
    artifacts with appropriate formatting and labeled fields.
  ```
  cases (AggregateResult) result:
    | agg-guard(id, name, outcome) =>
      group(
        soft-surround(2, 1,
          str("agg-guard("),
          separate(comma-sep,
            [list:
              concat(str("id: "), str(tostring(id))),
              concat(str("name: "), dquote(str(name))),
              concat(str("outcome: "), pp-guard-outcome(outcome))]),
          str(")")))
    | agg-test(id, name, max-score, outcome, part) =>
      group(
        soft-surround(2, 1,
          str("agg-test("),
          separate(comma-sep,
            [list:
              concat(str("id: "), str(tostring(id))),
              concat(str("name: "), dquote(str(name))),
              concat(str("max-score: "), number(max-score)),
              concat(str("outcome: "), pp-test-outcome(outcome)),
              concat(str("part: "), pp-option-string(part))]),
          str(")")))
    | agg-artifact(id, name, description, outcome) =>
      group(
        soft-surround(2, 1,
          str("agg-artifact("),
          separate(comma-sep,
            [list:
              concat(str("id: "), str(tostring(id))),
              concat(str("name: "), dquote(str(name))),
              concat(str("description: "),
                cases (Option) description:
                  | none => str("none")
                  | some(v) => pp-aggregate-output(v)
                end),
              concat(str("outcome: "), pp-artifact-outcome(outcome))]),
          str(")")))
  end
end

fun pretty-print-aggregate-result(
  result :: AggregateResult, width :: Number
) -> String:
  doc: ```
    Formats a single AggregateResult as a string with the given line width.
  ```
  doc = pp-aggregate-result(result)
  lines = doc.pretty(width)
  lines.join-str("\n")
end

fun pretty-print-aggregate-results(
  results :: List<AggregateResult>, width :: Number
) -> String:
  doc: ```
    Formats a list of AggregateResults as a string with the given line width,
    separating each result with blank lines.
  ```
  docs = results.map(pp-aggregate-result)
  combined = separate(concat(hardline, hardline), docs)
  lines = combined.pretty(width)
  lines.join-str("\n")
end

# END DISCLAIMER
