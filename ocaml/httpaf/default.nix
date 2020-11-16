{ lib, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let
  buildHttpaf = args: buildDunePackage ({
    version = "0.6.6-dev";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/httpaf/archive/5eb08d3f6dc2879e51e7ce7aa5682e20794a87ef.tar.gz;
      sha256 = "1b1q0vlqh6y53kj9wvmj0j4b7jbxhn6xkpjw88a5j2a3sfsvlm1w";
    };
  } // args);
in {
  httpaf = buildHttpaf {
    pname = "httpaf";
    propagatedBuildInputs = [ angstrom faraday ];
  };

  httpaf-lwt = buildHttpaf {
    pname = "httpaf-lwt";
    propagatedBuildInputs = [ httpaf gluten-lwt lwt ];
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
