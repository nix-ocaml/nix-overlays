const today = new Date();
const source_regex =
  /name = "nixos-unstable-(20[0-9\-]+)";.    url = https:\/\/github\.com\/nixos\/nixpkgs\/archive\/([0-9a-z]+)\.tar\.gz;.    sha256 = "([0-9a-z]+)";/s;

module.exports = async ({ github, context, core, require }) => {
  const https = require("https");
  const { readFile, writeFile } = require("fs/promises");
  const { exec } = require("child_process");

  const source_path = "./sources.nix";

  const revisions = new Promise((resolve, reject) => {
    https
      .get(
        "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision",
        (res) => {
          const response_data = [];
          res.on("data", (data) => {
            response_data.push(data);
          });

          res.on("end", () => {
            const response = Buffer.concat(response_data);
            const response_string = response.toString();
            const revisions = JSON.parse(response_string).data.result;
            resolve(revisions);
          });
        }
      )
      .on("error", reject);
  }).then((rev) => {
    const revision = rev.find((d) => d.metric.channel === "nixos-unstable");
    return revision;
  });

  const sources = readFile(source_path).then((source) => {
    return source.toString();
  });

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

  Promise.all([revisions, sources]).then(async ([revision, old_source]) => {
    const next_sha = revision.metric.revision;
    const next_url = `https://github.com/nixos/nixpkgs/archive/${next_sha}.tar.gz`;

    const next_sha256 = await get_sha256(next_url);

    const year = today.getFullYear();
    const month = (today.getMonth() + 1).toString().padStart(2, "0");
    const day = today.getDate().toString().padStart(2, "0");

    const next_source = old_source.replace(
      source_regex,
      `name = "nixos-unstable-${year}-${month}-${day}";
    url = ${next_url};
    sha256 = "${next_sha256}";`
    );

    writeFile(source_path, next_source);

    const [_full_match, _old_date, old_git_sha] =
      old_source.match(source_regex);
    const url = `https://github.com/NixOS/nixpkgs/compare/${old_git_sha}...${next_sha}`;

    return url;
  });
};
