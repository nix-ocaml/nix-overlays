{ lib, fetchFromGitHub, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let
  buildGluten = args: buildDunePackage ({
    version = "0.3.0-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "gluten";
      rev = "a45a0af6e4db3a711b97dd986b90404a00411060";
      sha256 = "17bpz4dpkn6yxapx1x4vjkqjdmhpy3s4rnqnry2cc4zc3h2rksdp";
    };
  } // args);

in rec {
    gluten = buildGluten {
      pname = "gluten";
      propagatedBuildInputs = [ faraday ];
    };

    gluten-lwt = buildGluten {
      pname = "gluten-lwt";
      propagatedBuildInputs = [ gluten lwt4 ];
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
