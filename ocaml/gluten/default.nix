{ lib, fetchFromGitHub, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let
  buildGluten = args: buildDunePackage ({
    version = "0.3.0-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "gluten";
      rev = "f7a840f251ef53a620ec9a68524f04e6af914fb3";
      sha256 = "1j3dnwgv6nl4j5733c1pcjqw7lscqyhppzavwv330a203xw2c1ax";
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
