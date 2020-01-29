{ lib, fetchFromGitHub, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let buildArchi = args: buildDunePackage ({
  version = "0.0.1-dev";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "archi";
    rev = "0f5de2d40319474b2317f802d599434478b1f860";
    sha256 = "1h1ifbpmpis7fcmfclvins9pj5q92g4j7cyh3v0bqvg18qp94j9y";
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
      propagatedBuildInputs = [ archi lwt4 ];
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

