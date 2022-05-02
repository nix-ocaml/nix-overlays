module.exports = async ({ github, context, core, require }) => {
  const https = require("https");
  const { URL } = require("url");
  const { readFileSync, writeFileSync } = require("fs");
  const { exec } = require("child_process");

  const http_request = (uri) => {
    return new Promise((resolve, reject) => {
      const url = new URL(uri);

      return https
        .get(
          {
            port: 443,
            path: url.pathname + url.search,
            protocol: url.protocol,
            hostname: url.hostname,
            method: "GET",
            headers: {
              "User-Agent": "GithubActions",
              Accept: "application/json",
            },
            url,
          },
          (res) => {
            const response_data = [];
            res.on("data", (data) => {
              response_data.push(data);
            });

            res.on("end", () => {
              const response = Buffer.concat(response_data);
              const response_string = response.toString();
              resolve(JSON.parse(response_string));
            });
          }
        )
        .on("error", reject);
    });
  };

  function update_flake() {
    return new Promise((resolve, reject) => {
      exec(`nix flake update`, (error, stdout, stderr) => {
        if (error) {
          return reject(error);
        }

        const shas = [
          ...stderr.matchAll(
            /NixOS\/nixpkgs\/(.*)' \(([0-9]{4}-[0-9]{2}-[0-9]{2})\)/gi
          ),
        ].map(([_, sha, date]) => ({
          sha,
          date,
        }));

        if (shas.length < 2) {
          return reject(new Error("No update"));
        }

        return resolve(shas);
      });
    });
  }

  const get_revisions = () =>
    http_request(
      "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision"
    )
      .then((res) => res.data.result)
      .then((rev) => [
        rev.find((d) => d.metric.channel === "nixos-unstable"),
        rev.find((d) => d.metric.channel === "nixos-unstable-small"),
      ]);

  const get_newest = (revisions) => {
    const urls = revisions
      .map((revision) => revision.metric.revision)
      .map(
        (commit_sha) =>
          `https://api.github.com/repos/nixos/nixpkgs/commits/${commit_sha}`
      );

    return Promise.all(urls.map(http_request)).then(([big, small]) => {
      const big_date = new Date(big.commit.committer.date);
      const small_date = new Date(small.commit.committer.date);
      if (big_date > small_date) {
        return {
          date: big_date,
          sha: big.sha,
          channel: "nixos-unstable",
        };
      } else {
        return {
          date: small_date,
          sha: small.sha,
          channel: "nixos-unstable-small",
        };
      }
    });
  };

  function get_ocaml_commits(sha1, sha2, page = 1, prev_commits = []) {
    return http_request(
      `https://api.github.com/repos/NixOS/nixpkgs/compare/${sha1}...${sha2}?per_page=100&page=${page}`
    ).then(({ commits = [] }) => {
      const all_commits = [...prev_commits, ...commits];
      if (commits.length < 100) {
        return all_commits.filter((c) => c.commit.message.startsWith("ocaml"));
      } else {
        return get_ocaml_commits(sha1, sha2, page + 1, all_commits);
      }
    });
  }

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

      const ocaml_packages_text = ocaml_commits.reduce((prev, commit) => {
        return `${prev}
* [${commit.commit.message}](${commit.html_url})`;
      }, "");

      const post_text = `
Commits touching OCaml packages:
${ocaml_packages_text}

Diff URL: ${url}
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
