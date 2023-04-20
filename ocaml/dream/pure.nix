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
  version = "1.0.0-alpha5";
  src = fetchFromGitHub {
    owner = "aantron";
    repo = "dream";
    rev = "1.0.0-alpha5";
    hash = "sha256-XMunaf/4xmZiB7EFqYM6lOiwt5bdH2h5Vtvq7oFtps4=";
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
