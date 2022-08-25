module.exports = async ({ github, context, core, require }) => {
  const {
    update_flake,
    get_revisions,
    get_newest,
    get_ocaml_commits,
    escapeForGHActions,
  } = require("./auto-update/lib.js");
  const { readFileSync, writeFileSync } = require("fs");

  const url = get_revisions()
    .then(get_newest)
    .then(async (revision) => {
      const flake_path = "./flake.nix";
      const old_flake = readFileSync(flake_path).toString("utf8");
      const next_flake = old_flake.replace(
        /rev=[a-z0-9]+/,
        `rev=${revision.sha}`
      );

      writeFileSync(flake_path, next_flake);

      const [prev_rev, curr_rev] = await update_flake();
      const url = `https://github.com/NixOS/nixpkgs/compare/${prev_rev.sha}...${curr_rev.sha}`;

      const ocaml_commits = await get_ocaml_commits(prev_rev.sha, curr_rev.sha);

      const ocaml_packages_text = ocaml_commits.map(({ commit, html_url }) => {
        const message = escapeForGHActions(commit.message);
        return `* <a href="${html_url}"><pre>${message}</pre></a>`;
      });

      const post_text = `
#### Commits touching OCaml packages:
${ocaml_packages_text.join("\n")}

#### Diff URL: ${url}
      `;

      // Only write the file if the commit hash has changed
      // Otherwise just cancel the workflow. We don't need to do anything
      if (curr_rev.sha.startsWith(prev_rev.sha)) {
        throw new Error("Shas were the same");
      }

      return post_text;
    })
    .catch((error) => {
      console.error(error);
      core.notice(error.message);
      github.rest.actions.cancelWorkflowRun({
        owner: context.repo.owner,
        repo: context.repo.repo,
        run_id: context.runId,
      });

      return "";
    });

  return url;
};
