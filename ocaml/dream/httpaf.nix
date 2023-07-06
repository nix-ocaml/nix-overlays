{ lib
, buildDunePackage
, dream-pure
, lwt
, lwt_ppx
, lwt_ssl
, ssl
, digestif
, faraday
, faraday-lwt-unix
, psq
, result
, ke
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

    faraday
    faraday-lwt-unix
    digestif
    ke
    psq
    result
  ];

  doCheck = false;

  meta = {
    description = "Easy-to-use, feature-complete Web framework without boilerplate";
    license = lib.licenses.mit;
  };
}
