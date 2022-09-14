{ buildDunePackage
, yojson
, ppx_deriving_yojson
, piaf-lwt
, uri
, logs
, lwt
}:

buildDunePackage {
  pname = "lambda-runtime";
  version = "0.1.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/aws-lambda-ocaml-runtime/archive/cf779dcd.tar.gz;
    sha256 = "0wx0lf2fzsbbw71q0lyc2q7h7jgf2pbvj3hf5wj2ma54k1vnx36j";
  };

  propagatedBuildInputs = [
    yojson
    ppx_deriving_yojson
    piaf-lwt
    uri
    logs
    lwt
  ];
}
