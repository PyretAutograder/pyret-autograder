#!/usr/bin/env node
// @ts-check
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
import { Spec } from "../../dist/schema.js";
import { program } from "commander";
import { join } from "node:path";
import { readFile } from "node:fs/promises";
import yaml from "yaml";

program
  .name("from-yaml")
  .arguments("<submission>")
  .option("-s, --solution <dir>", "Directory containing pawtograder.yml", ".")
  .action(async (submission, { solution }) => {
    const rawConfig = await readFile(join(solution, "pawtograder.yml"), "utf8");
    const config = yaml.parse(rawConfig, { merge: true });
    const spec = Spec.parse({
      solution_dir: solution,
      submission_dir: submission,
      config,
    });
    console.log(JSON.stringify(spec, null, 2));
  });

program.parse();
