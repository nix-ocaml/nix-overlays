const https = require("https");
const {URL} = require("url");

const {exec} = require("child_process");

function http_request(uri) {
  return new Promise((resolve, reject) => {
    const url = new URL(uri);

    return https
        .get({
          port : 443,
          path : url.pathname + url.search,
          protocol : url.protocol,
          hostname : url.hostname,
          method : "GET",
          headers : {
            "User-Agent" : "GithubActions",
            Accept : "application/json",
          },
          url,
        },
             (res) => {
               const response_data = [];
               res.on("data", (data) => { response_data.push(data); });

               res.on("end", () => {
                 const response = Buffer.concat(response_data);
                 const response_string = response.toString();
                 resolve(JSON.parse(response_string));
               });
             })
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
            /NixOS\/nixpkgs\/(.*)' \(([0-9]{4}-[0-9]{2}-[0-9]{2})\)/gi),
      ].map(([ _, sha, date ]) => ({
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

function get_revisions() {
  return http_request(
             "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision")
      .then((res) => res.data.result)
      .then((rev) => [rev.find((d) => d.metric.channel === "nixos-unstable"),
                      rev.find((d) =>
                                   d.metric.channel === "nixos-unstable-small"),
  ]);
}

const get_newest = (revisions) => {
  const urls =
      revisions.map((revision) => revision.metric.revision)
          .map((commit_sha) =>
                   `https://api.github.com/repos/nixos/nixpkgs/commits/${
                       commit_sha}`);

  return Promise.all(urls.map(http_request)).then(([ big, small ]) => {
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

function get_ocaml_commits(sha1, sha2, page = 1, prev_commits = []) {
  return http_request(`https://api.github.com/repos/NixOS/nixpkgs/compare/${
                          sha1}...${sha2}?per_page=100&page=${page}`)
      .then(({commits = []}) => {
        const all_commits = prev_commits.concat(commits);
        if (commits.length < 100) {
          return all_commits.filter((c) =>
                                        c.commit.message.startsWith("ocaml"));
        } else {
          return get_ocaml_commits(sha1, sha2, page + 1, all_commits);
        }
      });
}

function escapeForGHActions(s) {
  // Escape `"` and `$` characters in a string to work around the following
  // issue:
  // https://github.com/repo-sync/pull-request/issues/27
  return s.replace(/\$/g, '\\$').replace(/"/g, '\\"')
}

module.exports = {
  update_flake,
  get_revisions,
  get_newest,
  get_ocaml_commits,
  escapeForGHActions
}
