// @ts-check
import assert from "assert";
import { spawn } from "child_process";
import test from "node:test";
import { join } from "path";

test.it("should be able to communicate over file descriptor 3", (t, done) => {
  const child = spawn("node", [join(import.meta.dirname, "child.jarr")], {
    cwd: process.cwd(),
    stdio: ["pipe", "pipe", "pipe", "pipe"],
  });

  assert(child.stdin != null, "child's stdin shouldn't be null");

  child.stdin.write("hello");
  child.stdin.end();

  const fd3 = /** @type {NodeJS.ReadableStream} */ (child.stdio[3]);

  let received = "";
  let stdout = "";
  fd3.on("data", (d) => (received += d.toString()));
  child.stdout.on("data", (d) => (stdout += d.toString()));
  child.stderr.on("data", (d) => {
    throw Error(`Unexpected stderr: ${d}`);
  });

  child.on("exit", () => {
    t.assert.equal(received, '{"foo": "bar"}\n');
    t.assert.equal(
      stdout,
      "some stdout\nLooks shipshape, your test passed, mate!\n"
    );
    done();
  });
});
