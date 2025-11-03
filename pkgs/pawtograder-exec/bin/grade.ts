/*
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
*/

import { spawn } from "child_process";
import { createWriteStream } from "node:fs";
import { readFile } from "node:fs/promises";
import path from "node:path";
import { inspect } from "node:util";
import { Spec, z } from "pyret-autograder-pawtograder";
import yaml from "yaml";

const fd = (() => {
  const v = process.env.PA_RESULT_FD;
  return v != null && /^\d+$/.test(v) ? Number(v) : 3;
})();

async function write(str: string) {
  const stream = createWriteStream("", { fd });
  await new Promise((done, reject) => stream.end(str, () => done(undefined)));
  process.exit(0);
}

class ExecErr extends Error {
  constructor(
    public code: string,
    message?: string,
    options?: ErrorOptions,
  ) {
    super(message, options);
  }

  serialize() {
    return inspect(this, false, 5, false);
  }
}

async function fail(error: ExecErr) {
  const stream = createWriteStream("", { fd });
  let serialized;
  try {
    serialized = JSON.stringify(error.serialize());
  } catch {
    serialized = JSON.stringify({ code: "OtherErr", error });
  }
  await new Promise((done, reject) =>
    stream.end(serialized, () => done(undefined)),
  );

  process.exit(1);
}

async function resolveSpec(
  solution_dir: string,
  submission_dir: string,
  config: Record<string, unknown>,
) {
  const parseRes = Spec.safeParse({
    solution_dir,
    submission_dir,
    config,
  });

  if (parseRes.success) {
    return parseRes.data;
  } else {
    const pretty = z.prettifyError(parseRes.error);
    const err = `Invalid specification provided:\n${pretty}\n\nSee the cause field for the full error.`;

    throw new ExecErr("Spec", err, { cause: parseRes.error });
  }
}

async function grade(
  solution_dir: string,
  submission_dir: string,
): Promise<Record<string, unknown>> {
  if (solution_dir == null) {
    throw new ExecErr("InvalidSolutionDir");
  }
  if (submission_dir == null) {
    throw new ExecErr("InvalidSubmissionDir");
  }

  // TODO: handle missing pawtograder error
  const _config = await readFile(
    path.join(solution_dir, "pawtograder.yml"),
    "utf8",
  );
  const config = yaml.parse(_config, { merge: true });

  const spec = await resolveSpec(solution_dir, submission_dir, config);

  return new Promise((resolve, reject) => {
    const env = {
      PA_ARTIFACT_DIR: process.cwd(),
      ...process.env,
      PA_CURRENT_LOAD_PATH: submission_dir,
      PWD: submission_dir,
    };

    const child = spawn(
      process.execPath,
      [process.env.PYRET_MAIN_PATH ?? "src/main.cjs"],
      {
        env,
        cwd: submission_dir,
        //     [ stdin, stdout, stderr, custom]
        stdio: ["pipe", "inherit", "inherit", "pipe"],
      },
    );

    const fd3 = child.stdio[3] as NodeJS.ReadableStream;
    let output = "";
    fd3.setEncoding("utf8");
    fd3.on("data", (chunk: string) => (output += chunk));

    console.log("test");

    child.on("close", (code) => {
      console.log("grader ended");
      if (code !== 0) {
        return reject(
          new ExecErr("ExitCode", `Grader failed with code ${code}.`),
        );
      }
      try {
        resolve(JSON.parse(output));
      } catch (e) {
        reject(
          new ExecErr(
            "InvalidJSON",
            `Invalid JSON from grader: ${output}\n${e}`,
          ),
        );
      }
    });

    child.stdin!.write(JSON.stringify(spec));
    child.stdin!.end();
  });
}

const solution_dir = process.argv[2];
const submission_dir = process.argv[3];

try {
  const serialized = JSON.stringify(await grade(solution_dir, submission_dir));
  await write(serialized);
} catch (error: any) {
  console.error(error);
  await fail(error as ExecErr);
}
