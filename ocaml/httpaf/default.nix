{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildHttpaf = args: buildDunePackage ({
    version = "0.6.5-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "httpaf";
      rev = "3d28979024315d251bc8b658c1a70f64c0bd4bc4";
      sha256 = "10c4fxn0qja1q1blailrgvsb097s1prnmajnz9ppsdrx7w094idj";
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
