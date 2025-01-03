{ lib
, fetchFromGitHub
, buildDunePackage
, base64
, bigstringaf
, hmap
, lwt
, lwt_ppx
, ptime
, uri
, ppx_expect
, alcotest
, ppx_yojson_conv_lib
, bisect_ppx
}:

buildDunePackage rec {
  pname = "dream-pure";
  version = "1.0.0-alpha7";
  src = fetchFromGitHub {
    owner = "aantron";
    repo = "dream";
    rev = "deb4526387f72d3c5bb07f9a93b53ea38315b375";
    hash = "sha256-ZFwxGr69Nr84KYTGgJnD/2/1cdb7p5Knb0sA82PKwBo=";
  };

  propagatedBuildInputs = [
    base64
    bigstringaf
    hmap
    lwt
    lwt_ppx
    ptime
    uri
  ];

  checkInputs = [
    ppx_expect
    alcotest
    ppx_yojson_conv_lib
    bisect_ppx
  ];

  doCheck = false;

  meta = {
    description = "Easy-to-use, feature-complete Web framework without boilerplate";
    license = lib.licenses.mit;
  };
}
