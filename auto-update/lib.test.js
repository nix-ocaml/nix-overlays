const assert = require("node:assert/strict");
const {test} = require("node:test");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const timers = require("node:timers/promises");
const {get_revisions, get_newest, get_ocaml_commits, update_flake} = require("./lib.js");

test("channel lookup reports missing revisions clearly", async (t) => {
  t.mock.method(global, "fetch", async () => Response.json({
    status: "success", data: {result: []},
  }));
  await assert.rejects(get_revisions(), /no revision for nixos-unstable/);
});

test("commit lookup uses the supplied authenticated client and recovers from rate limiting", async (t) => {
  t.mock.method(timers, "setTimeout", async () => {});
  t.mock.method(console, "warn", () => {});
  const calls = [];
  const github = {rest: {repos: {getCommit: async (options) => {
    calls.push(options);
    if (calls.length === 1) throw Object.assign(new Error("Rate limit exceeded"), {
      status: 403, response: {headers: {"retry-after": "1"}},
    });
    return {data: {sha: options.ref, commit: {committer: {
      date: options.ref === "big" ? "2026-11-16T10:00:00Z" : "2026-11-15T10:00:00Z",
    }}}};
  }}}};
  const result = await get_newest(github, ["big", "small"].map((revision) => ({metric: {revision}})));
  assert.equal(result.sha, "big");
  assert.equal(result.channel, "nixos-unstable");
  assert.equal(calls.length, 3);
  for (const call of calls) {
    assert.equal(call.owner, "NixOS");
    assert.equal(call.repo, "nixpkgs");
    assert.equal(call.request.retries, 0);
  }
});

test("commit comparison authenticates every page and keeps relevant commits", async () => {
  const pages = [];
  const github = {rest: {repos: {compareCommitsWithBasehead: async (options) => {
    pages.push(options.page);
    assert.equal(options.basehead, "before...after");
    if (options.page === 1) return {data: {
      commits: Array.from({length: 100}, (_, i) => ({sha: `sha-${i}`, commit: {message: "other change"}})),
      files: [{filename: "pkgs/ocaml/foo.nix", blob_url: "https://github.com/NixOS/nixpkgs/blob/sha-0/pkgs/ocaml/foo.nix"}],
    }};
    return {data: {commits: [{sha: "last", commit: {message: "Update OCaml"}}]}};
  }}}};
  const {commits} = await get_ocaml_commits(github, "before", "after");
  assert.deepEqual(pages, [1, 2]);
  assert.deepEqual(commits.map((commit) => commit.sha), ["last", "sha-0"]);
});

test("comparison errors are propagated instead of producing an incomplete PR", async () => {
  const error = Object.assign(new Error("Forbidden"), {status: 403});
  const github = {rest: {repos: {compareCommitsWithBasehead: async () => { throw error; }}}};
  await assert.rejects(get_ocaml_commits(github, "before", "after"), (actual) => actual === error);
});

test("flake updates read revisions from the lock file and accept unchanged output", async (t) => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "auto-update-test-"));
  const previous_directory = process.cwd();
  const previous_path = process.env.PATH;
  t.after(() => {
    process.chdir(previous_directory);
    process.env.PATH = previous_path;
    fs.rmSync(directory, {recursive: true, force: true});
  });
  const lock = (rev) => JSON.stringify({nodes: {nixpkgs: {locked: {rev}}}});
  fs.writeFileSync(path.join(directory, "flake.lock"), lock("before"));
  fs.writeFileSync(path.join(directory, "next.lock"), lock("after"));
  fs.writeFileSync(path.join(directory, "nix"), '#!/bin/sh\ncp next.lock flake.lock\n', {mode: 0o755});
  process.chdir(directory);
  process.env.PATH = `${directory}:${previous_path}`;
  assert.deepEqual(await update_flake(), [{sha: "before"}, {sha: "after"}]);
  assert.deepEqual(await update_flake(), [{sha: "after"}, {sha: "after"}]);
  fs.writeFileSync(path.join(directory, "nix"), '#!/bin/sh\necho "Nix failed" >&2\nexit 1\n');
  await assert.rejects(update_flake(), /Nix failed/);
});
