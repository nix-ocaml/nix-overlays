const {exec} = require("child_process");
const {readFileSync} = require("fs");
const {promisify} = require("util");
const {get_json, with_retry} = require("./request.js");

async function update_flake() {
  const revision = () => JSON.parse(readFileSync("flake.lock", "utf8"))
    .nodes.nixpkgs.locked.rev;
  const previous = revision();
  await promisify(exec)("nix flake update");
  return [{sha: previous}, {sha: revision()}];
}

async function get_revisions() {
  const response = await get_json(
    "https://prometheus.nixos.org/api/v1/query?query=channel_revision");
  if (response.status !== "success" || !Array.isArray(response.data?.result)) {
    throw new Error(`Invalid channel response from prometheus.nixos.org: ${JSON.stringify(response)}`);
  }
  return ["nixos-unstable", "nixos-unstable-small"].map((channel) => {
    const revision = response.data.result.find((d) => d.metric?.channel === channel);
    if (!revision?.metric?.revision) {
      throw new Error(`prometheus.nixos.org returned no revision for ${channel}`);
    }
    return revision;
  });
}

const get_newest = (github, revisions) => {
  const commits = revisions.map(({metric}) => with_retry(() =>
    github.rest.repos.getCommit({
      owner: "NixOS", repo: "nixpkgs", ref: metric.revision,
      request: { retries: 0, timeout: 30000 },
    })).then(({data}) => data));

  return Promise.all(commits).then(([ big, small ]) => {
    const big_date = new Date(big.commit.committer.date);
    const small_date = new Date(small.commit.committer.date);
    if (big_date > small_date) {
      return {
        date : big_date,
        sha : big.sha,
        channel : "nixos-unstable",
      };
    } else {
      return {
        date : small_date,
        sha : small.sha,
        channel : "nixos-unstable-small",
      };
    }
  });
};

function get_commits(
  github,
  sha1,
  sha2,
  page = 1,
  prev_commits = { commits: {}, files: [] }
) {
  return with_retry(() => github.rest.repos.compareCommitsWithBasehead({
    owner: "NixOS", repo: "nixpkgs", basehead: `${sha1}...${sha2}`,
    per_page: 100, page,
    request: { retries: 0, timeout: 30000 },
  })).then(({data: res}) => {
    res.commits.forEach(commit => prev_commits.commits[commit.sha] = commit);
    const next_commits = {
      commits: prev_commits.commits,
      files: prev_commits.files.concat(res.files).filter(x => x != null),
    };
    if (res.commits.length < 100) {
      return next_commits;
    } else {
      return get_commits(github, sha1, sha2, page + 1, next_commits);
    }
  });
}

function get_ocaml_commits(github, sha1, sha2) {
  return get_commits(github, sha1, sha2).then(
    ({ commits = {}, files = [] }) => {
      const file_commits = files
        .filter((x) => x.filename.toLowerCase().includes("ocaml"))
        .map((x) => {
          const commit_sha = x.blob_url.split("/")[6];
          return commits[commit_sha];
        })
        .filter(x => x != null);
      return {
        commits: Object.values(commits).filter((c) =>
            c.commit.message.toLowerCase().includes("ocaml")
          ).concat(file_commits),
      };
    }
  );
}

function escapeForGHActions(s) {
  // Escape `"` and `$` characters in a string to work around the following
  // `` ` `` and `'` seems to be problematic as well
  // issue:
  // https://github.com/repo-sync/pull-request/issues/27
  return s.replace(/\$/g, '\\$')
      .replace(/"/g, '\\"')
      .replace(/`/g, '\\`')
      .replace(/\'/g, '\\\'');
}

module.exports = {
  update_flake,
  get_revisions,
  get_newest,
  get_ocaml_commits,
  escapeForGHActions
}
