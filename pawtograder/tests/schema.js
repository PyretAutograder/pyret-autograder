// @ts-check

import assert from "node:assert";
import t from "node:test";

import { Config } from "../dist/schema.js";

t.it("should be able to parse a simple config", () => {
  const config = {
    grader: "pyret",
    default_entry: "main.arr",
    graders: {
      "my-grader": {
        type: "well-formed",
      },
      "my-feedbot": {
        type: "feedbot",
        config: {
          function: "foo",
        },
      },
    },
  };

  const parsed = Config.parse(config);
  assert.equal(parsed.grader, "pyret");
  assert.equal(parsed.default_entry, "main.arr");
  assert.equal(parsed.graders.length, 2);
  assert.equal(parsed.graders[0][0], "my-grader");
  assert.equal(parsed.graders[0][1].type, "well-formed");
  assert.equal(parsed.graders[1][0], "my-feedbot");
  assert.equal(parsed.graders[1][1].type, "feedbot");
});
