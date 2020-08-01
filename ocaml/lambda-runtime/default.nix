{ ocamlPackages }:

with ocamlPackages;

let
  buildLambdaRuntime = args: buildDunePackage ({
    version = "0.1.0-dev";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/aws-lambda-ocaml-runtime/archive/1fe828601e0a7c3f2c97e5490f1b5db5bface553.tar.gz;
      sha256 = "03lxjcd7qx6v7dqjp6j83xzfn56vdhaxak8g6k3515lm87vx24vc";
    };
  } // args);

in {
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
