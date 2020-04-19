{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildHttpaf = args: buildDunePackage ({
    version = "0.6.5-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "httpaf";
      rev = "4e8e3da9e0dc7cd234f0ff259dce9ef89fb4f4fb";
      sha256 = "1yd5kchg7x1s1br1j70msdkk0vbxpiqwf68b3l2z49g2g71a1i8p";
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
