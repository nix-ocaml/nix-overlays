{ lib, fetchFromGitHub, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let
  buildGluten = args: buildDunePackage ({
    version = "0.3.0-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "gluten";
      rev = "1f13b531a9628bd302e606ed134ee514f83ae15f";
      sha256 = "1kvpxyc9g23hihpfrqwwpjkhyvddni6bmvchhcng7sl2czzwpn3n";
    };
  } // args);
  glutenPackages = rec {
    gluten = buildGluten {
      pname = "gluten";
      propagatedBuildInputs = [ httpaf ];
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
  };
in
  glutenPackages // (if (lib.versionOlder "4.08" ocamlVersion) then {
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
