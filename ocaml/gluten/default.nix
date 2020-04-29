{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildGluten = args: buildDunePackage ({
    version = "0.1.0-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "gluten";
      rev = "c421008647041dc70a1b1080770548f09fa834ab";
      sha256 = "1sbb81v6dq0jy230aksa57fsgvmk12yg3q6njz6swi10ygdwb95z";
    };
  } // args);
in rec {
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
}
