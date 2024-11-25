{ lib
, buildDunePackage
, dream-pure
, lwt
, lwt_ppx
, lwt_ssl
, ssl
, h2-lwt-unix
, httpun-lwt-unix
, httpun-ws
}:

buildDunePackage rec {
  pname = "dream-httpaf";
  inherit (dream-pure) src version;

  propagatedBuildInputs = [
    dream-pure
    lwt
    lwt_ppx
    lwt_ssl
    ssl

    httpun-lwt-unix
    h2-lwt-unix
    httpun-ws
  ];

  doCheck = false;

  meta = {
    description = "Easy-to-use, feature-complete Web framework without boilerplate";
    license = lib.licenses.mit;
  };
}
