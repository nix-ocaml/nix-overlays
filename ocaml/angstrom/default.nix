{ lib, fetchFromGitHub, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let
  buildAngstrom = args: buildDunePackage (rec {
    version = "0.14.0";
    src = fetchFromGitHub {
      owner = "inhabitedtype";
      repo = "angstrom";
      rev = version;
      sha256 = "18lry0mz32ynxlpygm12ybs9h4rs8svwdhq8kv8x9cqw92sl4q32";
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
        lwt4
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
