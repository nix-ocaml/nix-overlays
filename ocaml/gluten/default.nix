{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildGluten = args: buildDunePackage ({
    version = "0.1.0-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "gluten";
      rev = "0476eda7b20eed280742a9d8ff8f2431b7877cdc";
      sha256 = "1fw933xnp6bnxx87frmkfi4ki68jgv5inmg3a33lp0p5zgnpm6ah";
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
