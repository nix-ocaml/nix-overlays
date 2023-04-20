{ lib
, fetchFromGitHub
, buildDunePackage
, dream-pure
, lwt
, lwt_ppx
, lwt_ssl
, ssl
, angstrom
, base64
, bigstringaf
, digestif
, faraday
, faraday-lwt-unix
, psq
, result
, ppx_expect
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

    ppx_expect
    faraday
    faraday-lwt-unix
    digestif
    ke
    psq
  ];

  doCheck = false;

  meta = {
    description = "Easy-to-use, feature-complete Web framework without boilerplate";
    license = lib.licenses.mit;
  };
}
