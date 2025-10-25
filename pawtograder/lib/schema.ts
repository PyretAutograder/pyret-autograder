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

import { z } from "zod";

// ensure that consumers of the library use the same version of zod
export { z };

export const Spec = z.strictObject({
  solution_dir: z.string(),
  submission_dir: z.string(),
  get config() {
    return Config;
  },
});

export type Spec = z.infer<typeof Spec>;

// NOTE: intentionally allows extra keys at the top level pawtograder.yml
export const Config = z.object({
  grader: z.literal("pyret"),
  /**
   * The default entry point to the student's program, relative to
   * {@link Spec.submission_dir}
   */
  default_entry: z.string().optional(),
  get graders() {
    return z.record(z.string(), Grader).transform(Object.entries);
  },
});

export type Config = z.infer<typeof Config>;

const BaseGrader = z.strictObject({
  deps: z.string().array().optional(),
  /**
   * The path of the entry point to the student's program.
   *
   * Defaults to {@link Spec.config.default_entry}
   */
  entry: z.string().optional(),
});

const BaseGuard = BaseGrader;

const BaseScorer = BaseGrader.extend({
  points: z.number().nonnegative().optional(),
});

const BaseArtist = BaseGrader.extend({
  /** outfile, relative to the artifact directory */
  out: z.string()
});

const WellFormedGrader = BaseGuard.extend({
  type: z.literal("well-formed"),
});

const FunctionDefinedGrader = BaseGuard.extend({
  type: z.literal("function-defined"),
  config: z.strictObject({
    /** the name of the function to check the existance of */
    function: z.string(),
    /** the expected parameter arity */
    arity: z.int().nonnegative(),
  }),
});

const ConstantDefinedGrader = BaseGuard.extend({
  type: z.literal("constant-defined"),
  config: z.strictObject({
    /** the name of the constant to check the existance of */
    constant: z.string(),
  }),
});

const TestDiversityGrader = BaseGuard.extend({
  type: z.literal("test-diversity"),
  config: z.strictObject({
    /** the function to check the submission's test diversity of */
    function: z.string(),
    /** the minimum number of inputs that must be provided */
    min_in: z.int().nonnegative(),
    /** the minimum number of *actual* outputs that must be returned */
    min_out: z.int().nonnegative(),
  }),
});

const TrainingWheelsGrader = BaseGuard.extend({
  type: z.literal("training-wheels"),
  config: z.strictObject({
    /** whether to only check for mutation at the top level of the program */
    top_level_only: z.boolean(),
  }),
});

const ExamplarGrader = BaseScorer.extend({
  type: z.union([z.literal("wheat"), z.literal("chaff")]),
  config: z.strictObject({
    /** the path which contains the wheat/chaff implementation */
    path: z.string(),
    /** the name of the function to use */
    function: z.string(),
  }),
});

const FunctionalGrader = BaseScorer.extend({
  type: z.literal("functional"),
  config: z.strictObject({
    /** the path which contain the check block */
    path: z.string(),
    /** the name of the check block to use in the provided path */
    check: z.string(),
    /** the name of the function being tested (improves errors and grouping) */
    function: z.string().optional(),
  }),
});

const SelfTestGrader = BaseScorer.extend({
  type: z.literal("self-test"),
  config: z.strictObject({
    /** the name of the function to use */
    function: z.string(),
  }),
});

const FeedbotGrader = BaseGrader.extend({
  type: z.literal("feedbot"),
  config: z.strictObject({
    function: z.string(),
    model: z.string().optional(),
    provider: z.string().optional(),
    temperature: z.number().min(0).max(1).optional(),
    account: z.string().optional(),
    max_tokens: z.number().min(1).optional(),
  }),
});

const ProgramInspectorGrader = BaseGrader.extend({
  type: z.literal("program-inspector"),
});

const StyleGrader = BaseScorer.extend({
  type: z.literal("style"),
  config: z.strictObject({
    /*
    penalty: z.number()
    */
  })
});

const DocChkGrader = BaseScorer.extend({
  type: z.literal("docchk"),
  config: z.strictObject({
    function: z.string(),
  }),
})

const ImageArtifactGrader = BaseArtist.extend({
  type: z.literal("image-artifact"),
  config: z.strictObject({
    generator: z.string(),
    name: z.string(),
  }),
});

export const Grader = z.discriminatedUnion("type", [
  WellFormedGrader,
  FunctionDefinedGrader,
  ConstantDefinedGrader,
  TestDiversityGrader,
  TrainingWheelsGrader,
  ExamplarGrader,
  FunctionalGrader,
  SelfTestGrader,
  FeedbotGrader,
  ProgramInspectorGrader,
  StyleGrader,
  DocChkGrader,
  ImageArtifactGrader,
]);

export type Grader = z.infer<typeof Grader>;
