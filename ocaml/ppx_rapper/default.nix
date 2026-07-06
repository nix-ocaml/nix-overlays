{
  fetchFromGitHub,
  buildDunePackage,
  base,
  caqti,
  pg_query,
  ppxlib,
  lib,
}:

buildDunePackage {
  pname = "ppx_rapper";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "roddyyaga";
    repo = "ppx_rapper";
    rev = "ac71881c7ef1c40c4996c0080365bf2f12d275d1";
    hash = "sha256-2XTpk1kUakxddcR7ZBiv4hynV6dznDy//G7914azJKU=";
  };

  postPatch = lib.optionalString (lib.versionOlder ppxlib.version "0.36") ''
    substituteInPlace ppx/ppx_rapper.ml \
      --replace-fail "       ~constraint_:drop" ""
  '';

  buildInputs = [ ppxlib ];
  propagatedBuildInputs = [
    caqti
    pg_query
    base
  ];
}
