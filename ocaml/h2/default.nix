{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildH2 = args: buildDunePackage ({
    version = "0.5.0";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "ocaml-h2";
      rev = "2df073d588299434ce7960680d3c7fdf993ce9b4";
      sha256 = "100aj3j2qgyqbn1g85qp9sv1f0wfa22srd0f9f5bwwqnf74vch3q";
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
