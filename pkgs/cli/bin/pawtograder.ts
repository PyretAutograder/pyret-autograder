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

import chalk from "chalk";
import { spawn } from "node:child_process";
import { mkdtemp } from "node:fs/promises";
import path from "node:path";
import os from "os";

class InnerError extends Error {
  constructor(message: string) {
    super(message);
  }
}

export async function pawtograderAction(
  submission: string,
  { solution }: { solution: string },
) {
  const submissionPath = path.resolve(submission);
  const solutionPath = path.resolve(solution);

  console.log(
    `Grading submission at ${submissionPath} with the specification located in ${solutionPath}`,
  );

  const artifactDir = await (async () => {
    if (process.env.PA_ARTIFACT_DIR != null) return process.env.PA_ARTIFACT_DIR;
    const prefix = path.join(os.tmpdir(), "pyret-autograder-");
    return await mkdtemp(prefix);
  })();
  const result = await new Promise((resolve, reject) => {
    const env = {
      PA_CURRENT_LOAD_PATH: submissionPath,
      PA_ARTIFACT_DIR: artifactDir,
      ...process.env,
      PWD: submissionPath,
    };

    const child = spawn(
      process.env.PAWTOGRADER_PYRET_PATH ?? "pyret-pawtograder",
      [solutionPath, submissionPath],
      {
        env,
        cwd: submissionPath,
        //     [ stdin, stdout, stderr, custom]
        stdio: ["ignore", "pipe", "pipe", "pipe"],
      },
    );

    for (const [stream, target, name] of [
      [child.stdout!, process.stdout, chalk.blue`stdout`],
      [child.stderr!, process.stderr, chalk.red`stderr`],
    ] as const) {
      const prefix = `${name} » `;
      let leftover = "";
      stream.setEncoding("utf8");
      stream.on("data", (chunk) => {
        const lines = (leftover + chunk).split(/\n/);
        leftover = lines.pop()!;
        for (const line of lines) target.write(`${prefix}${line}\n`);
      });
      stream.on("end", () => {
        if (leftover) target.write(`${prefix}${leftover}\n`);
      });
    }

    const fd3 = child.stdio[3] as NodeJS.ReadableStream;
    let output = "";
    fd3.setEncoding("utf8");
    fd3.on("data", (chunk: string) => (output += chunk));

    child.on("close", (code) => {
      console.log("grader ended");
      if (code === 0) {
        try {
          resolve(JSON.parse(output));
        } catch (e) {
          reject(new Error(`Invalid JSON from grader: ${output}\n${e}`));
        }
      } else if (code === 1) {
        try {
          reject(new InnerError(JSON.parse(output)));
        } catch (e) {
          reject(new Error(`Invalid JSON from grader: ${output}\n${e}`));
        }
      } else {
        return reject(new Error(`Grader failed with code ${code}.`));
      }
    });
  });

  console.dir(result);
  console.log(`Artifact Dir: ${artifactDir}`);
}
