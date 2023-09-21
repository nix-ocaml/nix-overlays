{ lib
, ocaml
, buildDunePackage
, yojson
, csexp
, result
}:

let
  merlinVersion = "4.11";

  ocamlVersionShorthand = lib.concatStrings
    (lib.take 2 (lib.splitVersion ocaml.version));

  version = "${merlinVersion}-${ocamlVersionShorthand}";
in

buildDunePackage {
  pname = "merlin-lib";
  version = version;
  src =
    if (lib.versionOlder "5.1" ocaml.version) then
      builtins.fetchurl
        {
          url = https://github.com/ocaml/merlin/releases/download/v4.11-501/merlin-4.11-501.tbz;
          sha256 = "0ibsl5i7rfg62ds8b9628jn99czxqlcz6a2fs7wq151vwnm5k34p";
        }
    else
      if (lib.versionOlder "5.0" ocaml.version)
      then
        builtins.fetchurl
          {
            url = https://github.com/ocaml/merlin/releases/download/v4.11-500/merlin-4.11-500.tbz;
            sha256 = "00g59clv51r8hzfqib5p1bgkp7ms67k4igll2a126s4c61fqzayw";
          }
      else
        builtins.fetchurl {
          url = https://github.com/ocaml/merlin/releases/download/v4.11-414/merlin-4.11-414.tbz;
          sha256 = "0n4i1p8x4gzn3g8fdj765psxyqzr7swig3g85xmwbymjqy44wkc3";
        };

  buildInputs = [ yojson csexp result ];
}
