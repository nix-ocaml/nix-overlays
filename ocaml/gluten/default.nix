{ lib, ocamlPackages, ocamlVersion }:

with ocamlPackages;
let
  buildGluten = args: buildDunePackage (rec {
    version = "0.2.2-dev";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/gluten/archive/c5eada58.tar.gz;
      sha256 = "1a6dcrwpycrncjxhr76vaz57hxjhnnk7sps5k3xjl7948p9qy14d";
    };
  } // args);

in
{
  gluten = buildGluten {
    pname = "gluten";
    propagatedBuildInputs = [ bigstringaf faraday ke ];
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
} else { })
