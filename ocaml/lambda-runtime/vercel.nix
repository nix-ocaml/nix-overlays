{
  buildDunePackage,
  lambda-runtime,
  piaf,
  yojson,
  ppx_deriving_yojson,
  ppxlib_gt_0_37,
  lwt,
  base64,

}:

buildDunePackage {
  pname = "vercel";
  inherit (lambda-runtime) version src;
  buildInputs = [ ppxlib_gt_0_37 ];
  propagatedBuildInputs = [
    lambda-runtime
    piaf
    yojson
    ppx_deriving_yojson
    lwt
    base64
  ];
}
