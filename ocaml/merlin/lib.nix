{ lib
, ocaml
, buildDunePackage
, yojson
, csexp
, result
}:

let
  merlinVersion = "4.7";

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
          url = https://github.com/ocaml/merlin/releases/download/v4.9-501preview/merlin-4.9-501preview.tbz;
          sha256 = "10w9h7a3iqayb09hbgd9hhrca9x821mrrrbdchq1hqabhmkxnnl1";
        }
    else
      if (lib.versionOlder "5.0" ocaml.version)
      then
        builtins.fetchurl
          {
            url = https://github.com/ocaml/merlin/releases/download/v4.10-500/merlin-4.10-500.tbz;
            sha256 = "17a9lcmwnzvv1zcnj1amshg158j09csrjnha9f6qrxykq37r1pwv";
          }
      else
        builtins.fetchurl {
          url = https://github.com/ocaml/merlin/releases/download/v4.10-414/merlin-4.10-414.tbz;
          sha256 = "0rs7y2jz7mdkr7y29q6cig13gcfnlv384xp8x7s9cjl80jl4xbgx";
        };

  buildInputs = [ yojson csexp result ];
}
