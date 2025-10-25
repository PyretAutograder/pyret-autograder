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

import yaml from "yaml";
import { readFile, mkdtemp } from "node:fs/promises";
import { spawn } from "node:child_process";
import path from "node:path";
import { Config, Spec, z } from "pyret-autograder-pawtograder";
import chalk from "chalk";
import os from "os";

const PKG_ROOT = path.resolve(import.meta.dirname, "..");
const DEFAULT_COMPILED_PATH =
  path.join(PKG_ROOT, "build/pyret/lib-compiled") +
  ":" +
  path.join(PKG_ROOT, "build/pyret/cpo-compiled");

async function resolveSpec(submissionPath: string, solutionPath: string) {
  const rawConfig = await readFile(
    path.join(solutionPath, "pawtograder.yml"),
    "utf8",
  );

  const config: Config = yaml.parse(rawConfig, { merge: true });

  console.dir(config, { depth: 3 });

  const parseRes = Spec.safeParse({
    solution_dir: solutionPath,
    submission_dir: submissionPath,
    config,
  });

  if (parseRes.success) {
    return parseRes.data;
  } else {
    const pretty = z.prettifyError(parseRes.error);
    const err =
      chalk.redBright.bold`Invalid specification provided` +
      `:\n${chalk.yellow(pretty)}\n\n` +
      chalk.bold`See the ` +
      chalk.blackBright.bold`cause` +
      chalk.bold` field for the full error.`;

    throw new Error(err, { cause: parseRes.error });
  }
}

export async function pawtograderAction(
  submission: string,
  { solution }: { solution: string },
) {
  const submissionPath = path.resolve(submission);
  const solutionPath = path.resolve(solution);
  const spec = await resolveSpec(submissionPath, solutionPath);

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
      PA_PYRET_LANG_COMPILED_PATH: DEFAULT_COMPILED_PATH,
      PA_CURRENT_LOAD_PATH: submissionPath,
      PA_ARTIFACT_DIR: artifactDir,
      ...process.env,
      PWD: submissionPath,
    };

    const child = spawn(
      process.execPath,
      [path.join(import.meta.dirname, "../src/pawtograder.cjs")],
      {
        env,
        cwd: submissionPath,
        //     [ stdin, stdout, stderr, custom]
        stdio: ["pipe", "pipe", "pipe", "pipe"],
      },
    );

    console.log("grader started");

    for (const [stream, target, name] of [
      [child.stdout, process.stdout, chalk.blue`stdout`],
      [child.stderr, process.stderr, chalk.red`stderr`],
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
      if (code !== 0) {
        return reject(new Error(`Grader failed with code ${code}.`));
      }
      try {
        resolve(JSON.parse(output));
      } catch (e) {
        reject(new Error(`Invalid JSON from grader: ${output}\n${e}`));
      }
    });

    child.stdin.write(JSON.stringify(spec));
    child.stdin.end();
  });

  console.dir(result);
  console.log(`Artifact Dir: ${artifactDir}`);
}
