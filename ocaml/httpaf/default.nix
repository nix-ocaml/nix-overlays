{ lib, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let
  buildHttpaf = args: buildDunePackage ({
    version = "0.6.6-dev";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/httpaf/archive/dbeec79bf9922011162bd86b6aa1028cb6d4ffac.tar.gz;
      sha256 = "1x47bfjzpwy5jqz8wm883smda5f8vv4qnwvi9kd8bxg147crsxjz";
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
