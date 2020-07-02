{ lib, fetchFromGitHub, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let
  buildGluten = args: buildDunePackage (rec {
    version = "0.2.1";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "gluten";
      rev = version;
      sha256 = "1xm20hl55n1lngp9pf3ac4k6fjs7l6h23skmv19imnqjshg96iv5";
    };
  } // args);

in rec {
    gluten = buildGluten {
      pname = "gluten";
      propagatedBuildInputs = [ faraday ];
    };

    gluten-lwt = buildGluten {
      pname = "gluten-lwt";
      propagatedBuildInputs = [ gluten lwt ];
    };

    gluten-lwt-unix = buildGluten {
      pname = "gluten-lwt-unix";
      propagatedBuildInputs = [
        faraday-lwt-unix
        gluten-lwt
        lwt_ssl
      ];
    };
  } // (if (lib.versionOlder "4.08" ocamlVersion) then {
    gluten-async = buildGluten {
      pname = "gluten-async";
      propagatedBuildInputs = [
        faraday-async
        gluten
      ];
    };

    gluten-mirage = buildGluten {
      pname = "gluten-mirage";
      propagatedBuildInputs = [
        faraday-lwt
        gluten-lwt
        conduit-mirage
        mirage-flow
        cstruct
      ];
    };
  } else {})
