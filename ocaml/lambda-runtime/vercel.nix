{
  buildDunePackage,
  lambda-runtime,
  piaf,
  yojson,
  ppx_deriving_yojson,
  ppxlib,
  lwt,
  base64,

}:

buildDunePackage {
  pname = "vercel";
  inherit (lambda-runtime) version src;
  buildInputs = [ ppxlib ];
  propagatedBuildInputs = [
    lambda-runtime
    piaf
    yojson
    ppx_deriving_yojson
    lwt
    base64
  ];
}
