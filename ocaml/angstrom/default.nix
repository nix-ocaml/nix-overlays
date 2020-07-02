{ lib, fetchFromGitHub, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let
  buildAngstrom = args: buildDunePackage (rec {
    version = "0.14.1";
    src = fetchFromGitHub {
      owner = "inhabitedtype";
      repo = "angstrom";
      rev = version;
      sha256 = "1l69y0qspgi7kgrphyh7718hjb2sml1a9lljkp65bkqmmmi6ybly";
    };
  } // args);
  angstromPackages = rec {
    angstrom = buildAngstrom {
      pname = "angstrom";
      propagatedBuildInputs = [ bigstringaf result ];
    };

    angstrom-unix = buildAngstrom {
      pname = "angstrom-unix";
      propagatedBuildInputs = [ angstrom ];
    };

    angstrom-lwt-unix = buildAngstrom {
      pname = "angstrom-lwt-unix";
      propagatedBuildInputs = [
        angstrom
        lwt
      ];
    };
  };
in

  angstromPackages // (if (lib.versionOlder "4.08" ocamlVersion) then {
    angstrom-async = buildAngstrom {
      pname = "angstrom-async";
      propagatedBuildInputs = [ angstrom async ];
    };
  } else {})
