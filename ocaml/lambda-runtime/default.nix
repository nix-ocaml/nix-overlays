{ ocamlPackages }:

with ocamlPackages;
let
  buildLambdaRuntime = args: buildDunePackage ({
    version = "0.1.0-dev";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/aws-lambda-ocaml-runtime/archive/af70a42a527fdbcdb3eaab6776a997333a6becb4.tar.gz;
      sha256 = "14rrv4rdkn1q5yb1pdh2l2pqhx7lnx38wbgkbzd0hayalcn3d6d8";
    };
  } // args);

in
{
  lambda-runtime = buildLambdaRuntime {
    pname = "lambda-runtime";
    propagatedBuildInputs = [ yojson ppx_deriving_yojson piaf uri logs lwt ];
  };

  vercel = buildLambdaRuntime {
    pname = "vercel";
    propagatedBuildInputs = [
      lambda-runtime
      piaf
      yojson
      ppx_deriving_yojson
      lwt
      base64
    ];
  };
}
