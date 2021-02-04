{ lib, ocamlPackages, ocamlVersion }:

with ocamlPackages;
let
  buildGluten = args: buildDunePackage (rec {
    version = "0.2.1";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/gluten/archive/7c0e3f5f0001ca6dc88725443d998b6a4cad66a0.tar.gz;
      sha256 = "1p4k82m0ihpcvvy3klkp6d7xbym3zn21v80rl5jf218agv5pz9gc";
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
