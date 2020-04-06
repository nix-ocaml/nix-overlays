{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildH2 = args: buildDunePackage ({
    version = "0.5.0";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "ocaml-h2";
      rev = "2caffc49fbb429bd20f1cb7c6937534a9c7bac77";
      sha256 = "0hx0vaxcjkrbg411z0bcjdkaxq5mkzqvnxrkwnqgm80sccjp3pym";
    };
  } // args);
in rec {
  hpack = buildH2 {
    pname = "hpack";
    propagatedBuildInputs = [ angstrom faraday ];
  };

  h2 = buildH2 {
    pname = "h2";
    propagatedBuildInputs = [
      angstrom
      faraday
      base64
      psq
      hpack
      httpaf
    ];
  };

  h2-lwt = buildH2 {
    pname = "h2-lwt";
    propagatedBuildInputs = [ h2 lwt4 ];
  };

  h2-lwt-unix = buildH2 {
    pname = "h2-lwt-unix";
    propagatedBuildInputs = [
      h2-lwt
      faraday-lwt-unix
      lwt_ssl
    ];
  };
}
