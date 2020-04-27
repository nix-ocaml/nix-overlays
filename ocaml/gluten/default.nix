{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildGluten = args: buildDunePackage ({
    version = "0.1.0-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "gluten";
      rev = "7e9042f186b76a604f8139e381e6941c40e02fcd";
      sha256 = "1vndrchmvc8qvfiimcwrnflgsja3i9cp5zkarjnkwfwnb956irwb";
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
