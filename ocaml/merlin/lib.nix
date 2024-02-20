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
      fetchFromGitHub
        {
          owner = "ocaml";
          repo = "merlin";
          rev = "74191f149fe3967cd38d628c2063b00904196081";
          hash = "sha256-SnJDmi7SiTRaCJOp4cM/eWWdV8QBJMTYLg8TvhVqDuw=";
        }
    else
      if (lib.versionOlder "5.1" ocaml.version) then
        builtins.fetchurl
          {
            url = https://github.com/ocaml/merlin/releases/download/v4.13.1-501/merlin-4.13.1-501.tbz;
            sha256 = "1bf1f2flhicnkmgaph54ckclxgl288lml84i08hhicf5f1gy0mrm";
          }
      else
        if (lib.versionOlder "5.0" ocaml.version)
        then
          builtins.fetchurl
            {
              url = https://github.com/ocaml/merlin/releases/download/v4.12-500/merlin-4.12-500.tbz;
              sha256 = "0zwhcfb33wlzryd4pgwm4daviwf4qys8kmmy1ibsjd3klpn533wg";
            }
        else
          builtins.fetchurl {
            url = https://github.com/ocaml/merlin/releases/download/v4.13-414/merlin-4.13-414.tbz;
            sha256 = "00yvn5w21yg44jvy8m1z82pzpfv9fpz25kyrylb0kr517flz2p02";
          };

  buildInputs = [ yojson csexp result ];
}
