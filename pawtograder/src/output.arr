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
import lists as L
import json as J
import string-dict as SD
import ast as AST
import npm("pyret-autograder", "main.arr") as A
import file("./graders/feedbot.arr") as FB
import file("./graders/style.arr") as ST

include from A:
  module grading-helpers
end

provide:
  prepare-for-pawtograder,
  data PawtograderFeedback,
  data PawtograderTest,
  data PawtograderLint,
  data PawtograderLintStatus,
  data PawtograderTopLevelOutput,
  data PawtograderOutput,
  data PawtograderArtifact,
  data PawtograderAnnotations,
  data PawtograderFeedbackAuthor,
  data OutputFormat
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

data PawtograderFeedback:
  | pawtograder-feedback(
      tests :: L.List<PawtograderTest>,
      lint :: PawtograderLint,
      output :: PawtograderTopLevelOutput,
      max-score :: Option<Number>,
      score :: Option<Number>,
      artifacts :: L.List<PawtograderArtifact>,
      annotations :: L.List<PawtograderAnnotations>) with:
  method to-json(self) -> J.JSON block:
    sd = [SD.mutable-string-dict:]
    shadow add = add(sd, _, _, _)
    add("tests", self.tests, map-json(_.to-json()))
    add("lint", self.lint, _.to-json())
    add("output", self.output, _.to-json())
    add("max_score", self.max-score, num-to-json)
    add("score", self.score, num-to-json)
    add("artifacts", self.artifacts, map-json(_.to-json()))
    add("annotations", self.annotations, map-json(_.to-json()))
    J.j-obj(sd.freeze())
  end
end

data PawtograderTest:
  | pawtograder-test(
      part :: Option<String>,
      output-format :: OutputFormat,
      output :: String,
      hidden-output :: Option<String>,
      hidden-output-format :: Option<OutputFormat>,
      name :: String,
      max-score :: Option<Number>,
      score :: Option<Number>,
      hide-until-released :: Option<Boolean>,
      extra-data :: Option<SD.StringDict<Any>>,
      hidden-extra-data :: Option<SD.StringDict<Any>>) with:
  method to-json(self) -> J.JSON block:
    sd = [SD.mutable-string-dict:]
    shadow add = add(sd, _, _, _)
    add("part", self.part, J.to-json)
    add("output_format", self.output-format, _.to-json())
    add("output", self.output, J.to-json)
    add("hidden_output", self.hidden-output, J.to-json)
    add("hidden_output_format", self.hidden-output-format, _.to-json())
    add("name", self.name, J.to-json)
    add("max_score", self.max-score, num-to-json)
    add("score", self.score, num-to-json)
    add("hide_until_released", self.hide-until-released, _.to-json())
    add("extra_data", self.extra-data, J.to-json)
    add("hidden_extra_data", self.hidden-extra-data, J.to-json)
    J.j-obj(sd.freeze())
  end
end

data PawtograderLint:
  | pawtograder-lint(
      output-format :: Option<OutputFormat>,
      output :: String,
      status :: PawtograderLintStatus) with:
  method to-json(self) -> J.JSON block:
    sd = [SD.mutable-string-dict:]
    shadow add = add(sd, _, _, _)
    add("output_format", self.output-format, _.to-json())
    add("output", self.output, J.to-json)
    add("status", self.status, _.to-json())
    J.j-obj(sd.freeze())
  end
end

data PawtograderLintStatus:
  | pass with:
  method to-json(self) -> J.JSON:
    J.j-str("pass")
  end
  | fail with:
  method to-json(self) -> J.JSON:
    J.j-str("fail")
  end
end

data PawtograderTopLevelOutput:
  | pawtograder-top-level-output(
      visible :: Option<PawtograderOutput>,
      hidden :: Option<PawtograderOutput>,
      after-due-date :: Option<PawtograderOutput>,
      after-published :: Option<PawtograderOutput>) with:
  method to-json(self) -> J.JSON block:
    sd = [SD.mutable-string-dict:]
    add(sd, "visible", self.visible, _.to-json())
    add(sd, "hidden", self.hidden, _.to-json())
    add(sd, "after_due_date", self.after-due-date, _.to-json())
    add(sd, "after_published", self.after-published, _.to-json())
    J.j-obj(sd.freeze())
  end
end

data PawtograderOutput:
  | pawtograder-output(output-format :: Option<OutputFormat>, output :: String) with:
  method to-json(self) -> J.JSON block:
    sd = [SD.mutable-string-dict:]
    add(sd, "output_format", self.output-format, _.to-json())
    add(sd, "output", self.output, J.to-json)
    J.j-obj(sd.freeze())
  end
end

data PawtograderArtifact:
  | pawtograder-artifact(
      name :: String,
      path :: String,
      extra-data :: SD.StringDict<Any>
  ) with:
  method to-json(self) -> J.JSON block:
    sd = [SD.mutable-string-dict:]
    add(sd, "name", self.name, J.to-json)
    add(sd, "path", self.path, J.to-json)
    add(sd, "data", self.extra-data, J.to-json)
    J.j-obj(sd.freeze())
  end
end

data PawtograderAnnotations:
  | feedback-comment(
      author :: PawtograderFeedbackAuthor,
      message :: String,
      points :: Option<Number>,
      rubric-check-id :: Option<Number>,
      released :: Boolean) with:
  method to-json(self) block:
    sd = self.common-sd()
    J.j-obj(sd.freeze())
  end
  | feedback-line-comment(
      author :: PawtograderFeedbackAuthor,
      message :: String,
      points :: Option<Number>,
      rubric-check-id :: Option<Number>,
      released :: Boolean,
      line :: Number,
      file-name :: String) with:
  method to-json(self) block:
    sd = self.common-sd()
    add(sd, "line", self.line, J.to-json)
    add(sd, "file_name", self.file-name, J.to-json)
    J.j-obj(sd.freeze())
  end
  | feedback-artifact-comment(
      author :: PawtograderFeedbackAuthor,
      message :: String,
      points :: Option<Number>,
      rubric-check-id :: Option<Number>,
      released :: Boolean,
      artifact-name :: String) with:
  method to-json(self) block:
    sd = self.common-sd()
    add(sd, "artifact_name", self.artifact-name, J.to-json)
    J.j-obj(sd.freeze())
  end
sharing:
  method common-sd(self) block:
    sd = [SD.mutable-string-dict:]
    add(sd, "author", self.author, _.to-json())
    add(sd, "message", self.message, J.to-json)
    add(sd, "points", self.points, num-to-json)
    add(sd, "rubric_check_id", self.rubric-check-id, num-to-json)
    add(sd, "released", self.released, J.to-json)
    sd
  end
end

data PawtograderFeedbackAuthor:
  | feedback-author(
      name :: String,
      avatar-url :: String,
      flair :: Option<String>,
      flair-color :: Option<String>) with:
  method to-json(self) block:
    sd = [SD.mutable-string-dict:]
    add(sd, "name", self.name, J.to-json)
    add(sd, "avatar_url", self.avatar-url, J.to-json)
    add(sd, "flair", self.flair, J.to-json)
    add(sd, "flair_color", self.flair-color, J.to-json)
    J.j-obj(sd.freeze())
  end
end

data OutputFormat:
  | text
  | markdown
  | ansi
sharing:
  method to-json(self):
    cases (OutputFormat) self:
      | text => J.j-str("text")
      | markdown => J.j-str("markdown")
      | ansi => J.j-str("ansi")
    end
  end
end


fun aggregate-output-to-pawtograder(output :: A.AggregateOutput) -> {OutputFormat; String}:
  cases (A.AggregateOutput) output:
    | output-text(content) => {text; content}
    | output-markdown(content) => {markdown; content}
    | output-ansi(content) => {ansi; content}
  end
end

fun aggregate-to-pawtograder-output(output :: A.AggregateOutput) -> PawtograderOutput:
  {output-format; output-text} = aggregate-output-to-pawtograder(output)
  pawtograder-output(some(output-format), output-text)
end

fun prog-as-extra(prog :: AST.Program):
  [SD.string-dict:
    "pyret_repl", [SD.string-dict:
      "initial_code", prog.tosource().pretty(80)]]
  ^ some
end

fun feedbot-as-extra(info :: FB.FeedbotInfo):
  [SD.string-dict:
    "llm", info.serialize()]
  ^ some
end

fun extract-feedbot(trace :: A.ExecutionTrace):
  for fold(acc from [SD.string-dict:], entry from trace):
    cases(A.NodeResult) entry.result:
      | executed(_, minfo, _) =>
        # NOTE(dbp 2025-9-1): Type of info is Nothing | Some T
        if is-some(minfo) and FB.is-FeedbotInfo(minfo.value):
          acc.set(entry.id, minfo.value)
        else:
          acc
        end
      | else => acc
    end
  end
end

fun remove-feedbot(trace :: A.ExecutionTrace):
  for map(entry from trace):
    cases(A.NodeResult) entry.result:
      | executed(outcome, minfo, ctx) =>
        # NOTE(dbp 2025-9-1): Type of info is Nothing | Some T
        if is-some(minfo) and FB.is-FeedbotInfo(minfo.value):
          {id: entry.id, result: A.executed(outcome, nothing, ctx)}
        else:
          entry
        end
      | else => entry
    end
  end
end

fun prepare-for-pawtograder(output :: A.GradingOutput) -> J.JSON block:
  flattened = grading-helpers.aggregate-to-flat(output.aggregated)
  repl-programs = output.repl-programs
  feedbot-infos = extract-feedbot(output.trace)
  tests = for fold(acc from [list:], {id; flat} from flattened):
    cases (grading-helpers.FlatAggregateResult) flat:
      | flat-agg-test(name, max-score, score, go, so, part) =>
        {gof; gos} = aggregate-output-to-pawtograder(go)
        {sof; sos} = so.and-then(aggregate-output-to-pawtograder(_))
                       .and-then(lam({f; t}): {some(f); some(t)} end)
                       .or-else({none; none})

        {extra-data; hidden-extra-data} = cases(Option) repl-programs.get(id):
          | some(prog-run) =>
            cases(A.RanProgram) prog-run:
              | rp-general(prog) => {prog-as-extra(prog); none}
              | rp-staff(prog) => {none; prog-as-extra(prog)}
            end
          | none =>
            cases(Option) feedbot-infos.get(id):
              | some(info) => {feedbot-as-extra(info); none}
              | none => {none; none}
            end
        end

        test = pawtograder-test(
          part,
          gof, gos,
          sos, sof,
          name,
          some(max-score),
          some(score),
          none,
          extra-data,
          hidden-extra-data
        )
        link(test, acc)
      | flat-agg-art(_, _, _, _) => acc
    end
  end.reverse()

  artifacts = for fold(acc from [list:], {id; flat} from flattened):
    cases (grading-helpers.FlatAggregateResult) flat:
      | flat-agg-test(_, _, _, _, _, _) => acc
      | flat-agg-art(name, desc, path, format) =>
        # TODO: description
        extra-data = cases (A.ArtifactFormat) format:
          | png => [SD.string-dict: "format", "png"]
          | zip => [SD.string-dict: "format", "zip"]
          | else => [SD.string-dict:]
        end
        artifact = pawtograder-artifact(name, path, extra-data)
        link(artifact, acc)
    end
  end.reverse()

  trace-without-feedbot = remove-feedbot(output.trace)

  {gen-top; staff-top} = trace-without-feedbot
                         ^ grading-helpers.summarize-execution-traces
                         ^ {(r): {r; aggregate-to-pawtograder-output}}
                         ^ {({{g; s}; f}): {f(g); f(s)}}

  annotations = for fold(acc from [list:], entry from output.trace):
    cases(A.NodeResult) entry.result:
      | executed(_, info, _) =>
        if is-some(info) and ST.is-StyleInfo(info.value)
          and ST.is-style-info(info.value):
          file = info.value.file
          violations = info.value.violations
          for fold(shadow acc from acc, violation from violations):
            author = feedback-author(
              "Autograder",
              "https://api.dicebear.com/9.x/identicon/svg?seed=Autograder",
              none, none
            )
            annotation = feedback-line-comment(
              author,
              violation.style.to-string(),
              none,
              none,
              true,
              violation.line,
              file
            )
            link(annotation, acc)
          end
        else:
          acc
        end
      | else => acc
    end
  end.reverse()

  pawtograder-feedback(
    tests,
    pawtograder-lint(none, "", pass), # TODO: show guard failures here?
    pawtograder-top-level-output(some(gen-top), some(staff-top), none, none),
    none, none,
    artifacts,
    annotations
  ).to-json()
end

