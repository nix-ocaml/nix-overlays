{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildHttpaf = args: buildDunePackage ({
    version = "0.6.5-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "httpaf";
      rev = "addaf1c8d4008c6c1c150a1a4905c8ffe2647ef3";
      sha256 = "0iysbix5g5zss30bphsg8xysxlw4zgryj6c1c6zjcgrsx2kqvrlr";
    };
  } // args);
in rec {
  httpaf = buildHttpaf {
    pname = "httpaf";
    propagatedBuildInputs = [ angstrom faraday ];
  };

  httpaf-lwt = buildHttpaf {
    pname = "httpaf-lwt";
    propagatedBuildInputs = [ httpaf lwt4 ];
  };

  httpaf-lwt-unix = buildHttpaf {
    pname = "httpaf-lwt-unix";
    propagatedBuildInputs = [
      httpaf
      httpaf-lwt
      faraday-lwt-unix
      lwt_ssl
    ];
  };
}
