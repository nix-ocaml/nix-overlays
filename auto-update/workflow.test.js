const assert = require("node:assert/strict");
const {test} = require("node:test");
const run = require("../.github/workflows/auto-update.js");
const request = require("./request.js");

function workflow({current = "aaa", next = "bbb", failure, fail_at = "get_newest", lock_changed = true} = {}) {
  const files = {"./flake.nix": `rev=${current}`, "./flake.lock": "old lock"};
  const outputs = {};
  const failures = [];
  const infos = [];
  let compared = false;
  const lib = {
    get_revisions: async () => [],
    get_newest: async () => ({sha: next}),
    update_flake: async () => {
      if (lock_changed) files["./flake.lock"] = "new lock";
      return [{sha: current}, {sha: next}];
    },
    get_ocaml_commits: async () => {
      compared = true;
      return {commits: [{commit: {message: "Update OCaml"}, html_url: "https://example.com/commit"}]};
    },
    escapeForGHActions: (s) => s,
  };
  if (failure) lib[fail_at] = async () => { throw failure; };
  const promise = run({
    github: {rest: {actions: {cancelWorkflowRun: () => assert.fail("must not cancel workflow")}}},
    core: {
      setOutput: (key, value) => { outputs[key] = value; },
      setFailed: (message) => failures.push(message),
      info: (message) => infos.push(message),
    },
    require: (name) => {
      if (name === "./auto-update/lib.js") return lib;
      if (name === "./auto-update/request.js") return request;
      if (name === "fs") return {
        readFileSync: (name) => files[name],
        writeFileSync: (name, value) => { files[name] = value; },
      };
      assert.fail(`Unexpected require: ${name}`);
    },
  });
  return {promise, outputs, failures, infos, files, compared: () => compared};
}

test("unchanged sources succeed and skip commit comparison", async () => {
  const result = workflow({current: "aaa", next: "aaa", lock_changed: false});
  assert.equal(await result.promise, "");
  assert.equal(result.outputs.changed, false);
  assert.deepEqual(result.failures, []);
  assert.equal(result.compared(), false);
  assert.match(result.infos[0], /already up to date/);
});

test("changed sources return the PR body and enable publishing", async () => {
  const result = workflow();
  assert.match(await result.promise, /compare\/aaa\.\.\.bbb/);
  assert.equal(result.files["./flake.nix"], "rev=bbb");
  assert.equal(result.outputs.changed, true);
  assert.deepEqual(result.failures, []);
});

test("a lock-file-only update is not mistaken for a no-op", async () => {
  const result = workflow({current: "aaa", next: "aaa"});
  await result.promise;
  assert.equal(result.outputs.changed, true);
});

test("API errors fail with useful diagnostics instead of cancelling", async () => {
  const failure = Object.assign(new Error("API rate limit exceeded"), {
    status: 403,
    request: {url: "https://api.github.com/repos/NixOS/nixpkgs/commits/aaa"},
    response: {headers: {"x-github-request-id": "request-123", "x-ratelimit-remaining": "0"}},
  });
  const result = workflow({failure});
  assert.equal(await result.promise, "");
  assert.equal(result.outputs.changed, false);
  assert.equal(result.failures.length, 1);
  assert.match(result.failures[0], /HTTP 403: API rate limit exceeded/);
  assert.match(result.failures[0], /x-github-request-id=request-123/);
  assert.match(result.failures[0], /x-ratelimit-remaining=0/);
});

test("Nix and comparison failures also prevent publishing", async () => {
  for (const fail_at of ["update_flake", "get_ocaml_commits"]) {
    const result = workflow({failure: new Error("upstream failed"), fail_at});
    await result.promise;
    assert.equal(result.outputs.changed, false);
    assert.deepEqual(result.failures, ["upstream failed"]);
  }
});
