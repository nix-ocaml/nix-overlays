{ buildDunePackage
, lambda-runtime
, piaf-lwt
, yojson
, ppx_deriving_yojson
, lwt
, base64

}:

buildDunePackage {
  pname = "vercel";
  inherit (lambda-runtime) version src;
  propagatedBuildInputs = [
    lambda-runtime
    piaf-lwt
    yojson
    ppx_deriving_yojson
    lwt
    base64
  ];
}
