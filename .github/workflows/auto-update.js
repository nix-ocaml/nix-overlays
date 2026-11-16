module.exports = async ({ github, core, require }) => {
  const {
    update_flake,
    get_revisions,
    get_newest,
    get_ocaml_commits,
    escapeForGHActions,
  } = require("./auto-update/lib.js");
  const { describe_error } = require("./auto-update/request.js");
  const { readFileSync, writeFileSync } = require("fs");

  core.setOutput("changed", false);
  const url = get_revisions()
    .then((revisions) => get_newest(github, revisions))
    .then(async (revision) => {
      const flake_path = "./flake.nix";
      const old_flake = readFileSync(flake_path).toString("utf8");
      const old_lock = readFileSync("./flake.lock", "utf8");
      const next_flake = old_flake.replace(
        /rev=[a-z0-9]+/,
        `rev=${revision.sha}`
      );

      writeFileSync(flake_path, next_flake);

      const [prev_rev, curr_rev] = await update_flake();
      if (old_flake === next_flake && old_lock === readFileSync("./flake.lock", "utf8")) {
        core.info("Sources are already up to date.");
        return "";
      }
      const url = `https://github.com/NixOS/nixpkgs/compare/${prev_rev.sha}...${curr_rev.sha}`;

      const { commits: ocaml_commits } = await get_ocaml_commits(github, prev_rev.sha, curr_rev.sha);

      const ocaml_packages_text = ocaml_commits.map(({ commit, html_url }) => {
        const message = escapeForGHActions(commit.message);
        return `* <a href="${html_url}"><pre>${message}</pre></a>`;
      });

      const post_text = `
#### Commits touching OCaml packages:
${ocaml_packages_text.join("\n")}

#### Diff URL: ${url}

      `;

      core.setOutput("changed", true);
      return post_text;
    })
    .catch((error) => {
      core.setFailed(describe_error(error));
      return "";
    });

  return url;
};
