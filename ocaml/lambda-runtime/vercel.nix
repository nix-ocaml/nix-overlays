{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "vercel";
  inherit (lambda-runtime) version src;
  propagatedBuildInputs = [
    lambda-runtime
    piaf
    yojson
    ppx_deriving_yojson
    lwt
    base64
  ];
}
