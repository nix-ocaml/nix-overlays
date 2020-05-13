{ lib, fetchFromGitHub, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let
  buildH2 = args: buildDunePackage ({
    version = "0.5.0";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "ocaml-h2";
      rev = "e257868a494b772c8fd7dcf53c85dfaf4e2cc4b3";
      sha256 = "1shqml7f4g02zaab3i638lr0fdmi6l1c4nifwxxmw7pfgwki3344";
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
} // (if (lib.versionOlder "4.08" ocamlVersion) then {
    h2-mirage = buildH2 {
      pname = "h2-mirage";
      doCheck = false;
      propagatedBuildInputs = [
        conduit-mirage
        h2-lwt
        gluten-mirage
      ];
    };
  } else {})
