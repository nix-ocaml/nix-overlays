{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildLambdaRuntime = args: buildDunePackage ({
    version = "0.1.0-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "aws-lambda-ocaml-runtime";
      rev = "1fe828601e0a7c3f2c97e5490f1b5db5bface553";
      sha256 = "0r75h8fy045j0snrjiarnx045cwzj22p4z9j1skjsbkfvviw4p7s";
    };
  } // args);

in rec {
  lambda-runtime = buildLambdaRuntime {
    pname = "lambda-runtime";
    propagatedBuildInputs = [ yojson ppx_deriving_yojson piaf uri logs lwt ];
  };

  now = buildLambdaRuntime {
    pname = "now";
    propagatedBuildInputs = [
      lambda-runtime
      httpaf
      yojson
      ppx_deriving_yojson
      lwt
      base64
    ];
  };
}
