{ lib, fetchFromGitHub, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let buildArchi = args: buildDunePackage ({
  version = "0.1.1-dev";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "archi";
    rev = "51908bf4e381835ed04f88f8706022fb6f7b6fe3";
    sha256 = "0xvj8h9xa3gnkfijqdy16zgfi0m2v64pz489fy0rp45q1wy463v8";
  };

} // args);

  archiPkgs = rec {
    archi = buildArchi {
      pname = "archi";
      buildInputs = [ alcotest ];
      propagatedBuildInputs = [ hmap ];
      doCheck = true;
    };

    archi-lwt = buildArchi {
      pname = "archi-lwt";
      propagatedBuildInputs = [ archi lwt ];
      doCheck = false;
    };
  };
  in
  archiPkgs // (if (lib.versionOlder "4.08" ocamlVersion) then {
    archi-async = buildArchi {
      pname = "archi-async";
      propagatedBuildInputs = [ archi async ];

      doCheck = false;
    };
  } else {})

