{ lib, ocamlVersion, ocamlPackages }:

with ocamlPackages;

let buildArchi = args: buildDunePackage ({
  version = "0.1.1-dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/archi/archive/51908bf4e381835ed04f88f8706022fb6f7b6fe3.tar.gz;
    sha256 = "12z4mmw5ir8h83kyl4hf2hnmrir2fshqazpfbgdycmczplypl69h";
  };

} // args);

  archiPkgs = {
    archi = buildArchi {
      pname = "archi";
      checkInputs = [ alcotest ];
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

