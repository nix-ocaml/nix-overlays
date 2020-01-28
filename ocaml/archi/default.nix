{ lib, fetchFromGitHub, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let buildArchi = args: buildDunePackage ({
  version = "0.0.1-dev";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "archi";
    rev = "5222154cfc6c5012fbf120abd8f87fc31d5d109a";
    sha256 = "0s9zzz6s18cqmbrbadicpz1gy8z743rvzvfxvl2jwdc4nmc8rarp";
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

