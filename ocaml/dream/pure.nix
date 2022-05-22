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
  version = "1.0.0-alpha4";
  src = fetchFromGitHub {
    owner = "aantron";
    repo = "dream";
    rev = "7f196a2573e535b8307e8dc418c2f6094cfeed33";
    sha256 = "oC1L/pgrvyed0SimAPtIvPcPzDzJhyKjd71J7zu+R88=";
    fetchSubmodules = true;
    leaveDotGit = false;
    deepClone = false;
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

  preBuild = ''
    rm -rf src/vendor
  '';

  meta = {
    description = "Easy-to-use, feature-complete Web framework without boilerplate";
    license = lib.licenses.mit;
  };
}
