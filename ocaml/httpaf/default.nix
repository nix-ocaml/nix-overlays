{ lib, fetchFromGitHub, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let
  buildHttpaf = args: buildDunePackage ({
    version = "0.6.5-dev";
    # Until this is in
    # https://github.com/inhabitedtype/httpaf/pull/176
    doCheck = false;
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "httpaf";
      rev = "d7fccccfe78ad0dc508e3b3f41b661af5c49bcbf";
      sha256 = "185ng8pjz8dfk690h8yvhp9wcbv01s5m9n9d9fj6mbv20y1cv793";
    };
  } // args);
in rec {
  httpaf = buildHttpaf {
    pname = "httpaf";
    propagatedBuildInputs = [ angstrom faraday ];
  };

  httpaf-lwt = buildHttpaf {
    pname = "httpaf-lwt";
    propagatedBuildInputs = [ httpaf gluten-lwt lwt4 ];
  };

  httpaf-lwt-unix = buildHttpaf {
    pname = "httpaf-lwt-unix";
    propagatedBuildInputs = [
      httpaf
      httpaf-lwt
      gluten-lwt-unix
      faraday-lwt-unix
      lwt_ssl
    ];
  };
} // (if (lib.versionOlder "4.08" ocamlVersion) then {
    httpaf-mirage = buildHttpaf {
      pname = "httpaf-mirage";
      doCheck = false;
      propagatedBuildInputs = [
        conduit-mirage
        httpaf-lwt
        gluten-mirage
      ];
    };
  } else {})
