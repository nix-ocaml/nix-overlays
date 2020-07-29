{ lib, fetchFromGitHub, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let
  buildGluten = args: buildDunePackage (rec {
    version = "0.2.1";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "gluten";
      rev = "4271bfccaba99be9fcb1f8794faa547db6491834";
      sha256 = "0aai21p0xp810axan50h9ss84sv0xxl9fmc203hsrr3j1aygm5r9";
    };
  } // args);

in {
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
