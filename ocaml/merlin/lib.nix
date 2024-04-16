{ fetchFromGitHub
, lib
, ocaml
, buildDunePackage
, yojson
, csexp
, result
}:

let
  merlinVersion = "4.12";

  ocamlVersionShorthand = lib.concatStrings
    (lib.take 2 (lib.splitVersion ocaml.version));

  version = "${merlinVersion}-${ocamlVersionShorthand}";
in

buildDunePackage {
  pname = "merlin-lib";
  version = version;
  src =
    if (lib.versionOlder "5.2" ocaml.version)
    then
      builtins.fetchurl
        {
          url = https://github.com/ocaml/merlin/releases/download/4.14-502_preview2/merlin-4.14-502.preview2.tbz;
          sha256 = "1xb7lzj2rrgd77v5795gfgwdnja31rvj8n5j289kwvsvixki5yq8";
        }
    else
      if (lib.versionOlder "5.1" ocaml.version) then
        builtins.fetchurl
          {
            url = https://github.com/ocaml/merlin/releases/download/v4.14-501/merlin-4.14-501.tbz;
            sha256 = "14m20d9ad57lphw4a8hy8h6p5473la57hhln8b7c4n20j9pfksdp";
          }
      else
        if (lib.versionOlder "5.0" ocaml.version)
        then
          builtins.fetchurl
            {
              url = https://github.com/ocaml/merlin/releases/download/v4.14-500/merlin-4.14-500.tbz;
              sha256 = "03nps5mbh5lzf88d850903bz75g5sk33qc3zi7c0qlkmz0jg68zc";
            }
        else
          builtins.fetchurl {
            url = https://github.com/ocaml/merlin/releases/download/v4.14-414/merlin-4.14-414.tbz;
            sha256 = "0gcrfgcp4m0wk1i3ci423qdn83a2qf5zfp2dbkfh25bwlg58q0br";
          };

  buildInputs = [ yojson csexp result ];
}
