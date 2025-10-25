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

import npm("pyret-autograder", "main.arr") as A
import slice-from-function from npm("pyret-autograder", "common/slicing.arr")
import parse-path from npm("pyret-autograder", "common/ast.arr")
import json as J
import string-dict as SD

include either

provide:
  data FeedbotInfo,
  mk-feedbot,
end

data FeedBotRateLimit:
  | feedbot-rate-limit(
      cooldown :: Number
    ) with:
    method serialize(self):
      [SD.string-dict:
        "cooldown", self.cooldown
      ]
    end
end

data FeedbotInfo:
  | feedbot-info(
      model :: String,
      provider :: String,
      prompt :: String,
      temperature :: Number,
      account :: Option<String>,
      max-tokens :: Number,
      rate-limit :: FeedBotRateLimit
    ) with:
    method serialize(self):
      [SD.string-dict:
        "model", self.model,
        "provider", self.provider,
        "prompt", self.prompt,
        "temperature", self.temperature,
        "account", self.account.or-else(nothing),
        "max_tokens", self.max-tokens,
        "rate_limit", self.rate-limit.serialize(),
        "type", "v1"
      ]
    end
end

system-prompt = "You are FeedBot, an expert teacher for a programming class which uses the Design Recipe from the textbook How to Design Programs, Second Edition. The language used by the course is Pyret, which is NOT Python. Do not be confused by the syntax -- and do not give bad advice based on misinterpreting the code as Python. Your role is to facilitate learning by giving small hints as feedback on student submissions, so that they do not get stuck. Your role is NOT to tell them the correct answer or provide code of any kind. Your only job is to point them in the right direction. DO NOT answer with code or solutions of any kind. You will describe ONLY THE FIRST issue that you come across, going through the steps of the design recipe in order as appropriate, so that the student can fix each part before moving onto the next. You will address the student using \"you\", \"your\", etc. You will provide a brief response with a MAXIMUM of 1 PARAGRAPH. Do not include greetings, farewells, niceties, etc. ACCURACY IS HIGHLY IMPORTANT. THE STUDENTS ARE RELYING ON YOU. USE MAXIMUM EFFORT.\n\n"

general-prompt = lam(fn-name): "You will be given an entire submission file, but you will be tasked with only giving feedback on a single function, `" + fn-name + "`. There may be issues in other parts of the file, but focus only on issues that are directly related to the function that is identified. \n\nYou will first plan your response by going through the steps of the design recipe one-by-one. For each step, you will:\n(a) analyze whether the step is present and if so, analyze how satisfactorily the step was completed. Now use your planning to select the FIRST step of the design recipe that was not satisfactorily completed. Do not address earlier steps that are satisfactorily completed. If all steps are satisfactory, simply say \"Well done, looks good\". DO NOT NITPICK SMALL DETAILS ON CORRECT SOLUTIONS, AND DO NOT REQUIRE THEM TO EXPLAIN THEIR IMPLEMENTATIONS. There should be no comments needed in correct solutions. Otherwise, address the student directly with your BRIEF, MAXIMUM TWO SENTENCES response informing the student about ONLY THE FIRST STEP they need to improve. NEVER EVER PROVIDE CODE, NEVER EVER COMMENT ON MULTIPLE STEPS, and POINT THE STUDENT TO WHAT IS WRONG BUT DO NOT TELL THEM HOW TO FIX IT. \n\n" end

function-dr-prompt = "Here are the design recipe steps for functions. Follow them exactly in your planning.\n1. Signature: type annotations on all inputs and as the output of the function.\n2. Purpose Statement: the `doc: ` string -- a sentence or two explaining what the function does.\n3. Tests: 2 or more meaningfully different tests for the function, in a `where: ` block.\n4. Function Body: the actual declaration and implementation of the function.\nThe student may have written other \"helper\" functions (defined locally or outside), which will be called in the body of the main function. Students must also follow the design recipe for \"helper\" functions. CONSIDER ALL FUNCTIONS, INCLUDING \"HELPER\"s, in your planning and response.\n\n"

final-instructions-prompt = "\n\nBegin your response now. Remember to first PLAN your response, and then ANSWER CONCISELY, exactly as described -- DO NOT MENTION EARLIER STEPS THAT DO NOT HAVE ISSUES. DO NOT SUMMARIZE HOW THEY WENT. JUST MENTION THE FIRST STEP WITH AN ISSUE."

fun score-feedbot(
  path :: String, fn-name :: String, model :: Option<String>,
  provider :: Option<String>, temperature :: Number, account :: Option<String>,
  max-tokens :: Number
):
  cases (Either) parse-path(path):
    | left(err) =>
      left({
        to-string: lam():
          to-repr(err)
        end
      })
    | right(prog) =>
      sliced = slice-from-function(prog, fn-name)
      prompt = system-prompt + general-prompt(fn-name) + function-dr-prompt + "GIVE DESIGN RECIPE FEEDBACK AS SPECIFIED ON FUNCTION `" + fn-name + "`, WHICH APPEARS IN THE FOLLOWING PROGRAM:\n```pyret\n" + sliced.tosource().pretty(80).join-str("\n") + "```" + final-instructions-prompt

      info = feedbot-info(
        model.or-else("gpt-5-mini"),
        provider.or-else("openai"),
        prompt,
        temperature,
        account,
        max-tokens,
        feedbot-rate-limit(60)
      )
      right({0; info})
  end
end

fun fmt-feedbot(_, info :: FeedbotInfo) -> A.ComboAggregate:
  general = A.output-text("")
  staff = none
  {general; staff}
end

fun mk-feedbot(
  id :: A.Id, deps :: List<A.Id>, path :: String, fn-name :: String,
  model :: Option<String>, provider :: Option<String>, temperature :: Number,
  account :: Option<String>, max-tokens :: Number
):
  name = "Feedbot for " + fn-name
  scorer = lam():
    score-feedbot(
      path, fn-name, model, provider, temperature, account, max-tokens
    )
  end
  fmter = fmt-feedbot
  max-score = 0
  part = some(fn-name)
  A.mk-simple-scorer(id, deps, scorer, name, max-score, fmter, part)
end
