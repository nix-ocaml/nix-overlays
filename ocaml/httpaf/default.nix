{ lib, fetchFromGitHub, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let
  buildHttpaf = args: buildDunePackage ({
    version = "0.6.5-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "httpaf";
      rev = "e2ba2ad95cb653032fd6533cc0e9eeb7020a9cbd";
      sha256 = "1s6yphh2dijkjiw4p8i06cxm67ns6j0r6mhgijagf6bmgcb50bq5";
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
    httpaf-async = buildHttpaf {
      pname = "httpaf-async";
      doCheck = false;
      propagatedBuildInputs = [
        httpaf
        async
        gluten-async
        faraday-async
        async_ssl
      ];
    };

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
