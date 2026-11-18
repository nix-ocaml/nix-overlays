{
  buildDunePackage,
  cf,
  lwt,
  alcotest,
}:

buildDunePackage {
  pname = "cf-lwt";
  inherit (cf) version src meta;
  propagatedBuildInputs = [
    cf
    lwt
  ];
  checkInputs = [ alcotest ];
  doCheck = true;
}
