#!/usr/bin/env node
/*
  Copyright (C) 2025 ironmoon <me@ironmoon.dev>

  This file is part of pyret-autograder-cli.

  pyret-autograder-cli is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as published by
  the Free Software Foundation, either version 3 of the License, or (at your
  option) any later version.

  pyret-autograder-cli is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License
  for more details.

  You should have received a copy of the GNU Affero General Public License
  with pyret-autograder-cli. If not, see <http://www.gnu.org/licenses/>.
*/

import { program } from "commander";
import Package from "../package.json" with { type: "json" };
import { pawtograderAction } from "./pawtograder.js";

program
  .name("pyret-autograder-cli")
  .description(
    "Run Pyret autograders using the same configuration expected by an adaptor.",
  )
  .version(Package.version);

program
  .command("pawtograder")
  .description("Run the autograder on a Pawtograder specification.")
  .argument("<submission>", "The submission directory to use.")
  .option(
    "-s, --solution <dir>",
    "The directory containing the solution and autograder specification.",
    ".",
  )
  .action(pawtograderAction);

program.addHelpText(
  "afterAll",
  `
License:
  pyret-autograder-cli is licensed under the GNU Affero General Public License v3.0 or later.
  See <https://www.gnu.org/licenses/> for more information.`,
);

program.parse();
