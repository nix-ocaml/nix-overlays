const { url } = require("inspector");

const source_regex =
  /name = "nixos-unstable-(20[0-9\-]+)";.    url = https:\/\/github\.com\/nixos\/nixpkgs\/archive\/([0-9a-z]+)\.tar\.gz;.    sha256 = "([0-9a-z]+)";/s;

module.exports = async ({ github, context, core, require }) => {
  console.log("running...");
  const https = require("https");
  const { URL } = require("url");
  const { readFileSync, writeFileSync } = require("fs");
  const { exec } = require("child_process");

  const http_request = (uri) => {
    return new Promise((resolve, reject) => {
      console.log("http request to: ", uri);
      const url = new URL(uri);

      console.log(url);

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
              console.log("is it ever here?");
              const response = Buffer.concat(response_data);
              const response_string = response.toString();
              resolve(JSON.parse(response_string));
            });
          }
        )
        .on("error", reject);
    });
  };

  const get_revisions = () =>
    http_request(
      "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision"
    )
      .then((res) => res.data.result)
      .then((rev) => [
        rev.find((d) => d.metric.channel === "nixos-unstable"),
        rev.find((d) => d.metric.channel === "nixos-unstable-small"),
      ]);

  function get_sha256(url) {
    return new Promise((resolve, reject) => {
      exec(
        `nix-prefetch-url --type sha256 --unpack ${url}`,
        (error, stdout, stderr) => {
          if (error) {
            return reject(error);
          }

          const lines = stdout.trim().split("\n");
          resolve(lines[0]);
        }
      );
    });
  }

  const get_newest = (revisions) => {
    console.log(revisions);
    const urls = revisions
      .map((revision) => revision.metric.revision)
      .map(
        (commit_sha) =>
          `https://api.github.com/repos/nixos/nixpkgs/commits/${commit_sha}`
      );

    return Promise.all(urls.map(http_request)).then(([big, small]) => {
      console.log({
        big,
        small,
        big_comitter: big.commit.committer,
        small_committer: small.commit.committer,
      });
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

  const url = get_revisions()
    .then(get_newest)
    .then(async (revision) => {
      const next_sha = revision.sha;
      const next_url = `https://github.com/nixos/nixpkgs/archive/${next_sha}.tar.gz`;
      const source_path = "./sources.nix";

      const next_sha256 = await get_sha256(next_url);

      const year = revision.date.getFullYear();
      const month = (revision.date.getMonth() + 1).toString().padStart(2, "0");
      const day = revision.date.getDate().toString().padStart(2, "0");

      const old_source = readFileSync(source_path).toString();
      const next_source = old_source.replace(
        source_regex,
        `name = "${revision.channel}-${year}-${month}-${day}";
    url = ${next_url};
    sha256 = "${next_sha256}";`
      );

      writeFileSync(source_path, next_source);

      const [_full_match, _old_date, old_git_sha] =
        old_source.match(source_regex);
      const url = `https://github.com/NixOS/nixpkgs/compare/${old_git_sha}...${next_sha}`;

      return url;
    });

  return url;
};
