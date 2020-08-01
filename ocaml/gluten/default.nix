{ lib, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let
  buildGluten = args: buildDunePackage (rec {
    version = "0.2.1";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/gluten/archive/d3540d576f54aba1e41480aa89d4cdbad4167604.tar.gz;
      sha256 = "1vlxh02gb0amsap8xp65m6zzn3hgp35w4xg0qiz369bxd6mndqz3";
    };
  } // args);

in {
    gluten = buildGluten {
      pname = "gluten";
      propagatedBuildInputs = [ faraday ];
    };

    gluten-lwt = buildGluten {
      pname = "gluten-lwt";
      propagatedBuildInputs = [ gluten lwt ke ];
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
