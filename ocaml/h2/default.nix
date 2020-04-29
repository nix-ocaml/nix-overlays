{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildH2 = args: buildDunePackage ({
    version = "0.5.0";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "ocaml-h2";
      rev = "d9db6697bf6dcf3c5cfb63b87699a0cd50562c67";
      sha256 = "0qjrhxmm7k3x2vnyw3syyimm5ks6n644flid4nmpj8xp8hxvchap";
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
    propagatedBuildInputs = [ gluten-lwt h2 lwt4 ];
  };

  h2-lwt-unix = buildH2 {
    pname = "h2-lwt-unix";
    propagatedBuildInputs = [
      gluten-lwt-unix
      h2-lwt
      faraday-lwt-unix
      lwt_ssl
    ];
  };
}
