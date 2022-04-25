const source_regex = /name = "nixos-unstable-(small-)?(20[0-9\-]+)";/s;

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
            /NixOS\/nixpkgs\/(.*)' \(([0-9]{4}-[0-9]{2}-[0-9]{2})\)/g
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

  const url = update_flake()
    .then(async ([prev_rev, curr_rev]) => {
      const source_path = "./sources.nix";

      const flake_lock = JSON.parse(readFileSync("./flake.lock"));

      const old_source = readFileSync(source_path).toString();
      const next_source = old_source.replace(
        source_regex,
        `name = "${flake_lock.nodes.nixpkgs.original.ref}-${curr_rev.date}";`
      );

      const [_full_match, _channel_variant] = old_source.match(source_regex);
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
      } else {
        writeFileSync(source_path, next_source);
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
