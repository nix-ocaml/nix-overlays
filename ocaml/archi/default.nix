{ lib, fetchFromGitHub, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let buildArchi = args: buildDunePackage ({
  version = "0.0.1-dev";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "archi";
    rev = "b19e5bfa5fe25d753feb239a73400984a10e4c97";
    sha256 = "1ad0jqycqi4a883maraj8jazq15560jhcia5rk9m11vw5p5wzcmr";
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

