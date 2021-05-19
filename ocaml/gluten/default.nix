{ lib, ocamlPackages, ocamlVersion }:

with ocamlPackages;
let
  buildGluten = args: buildDunePackage (rec {
    version = "0.2.2-dev";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/gluten/archive/475c361.tar.gz;
      sha256 = "0la1r30k6siv064nvlml85qk7m70ysnzwq0mnk7vm34656vh6m05";
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
