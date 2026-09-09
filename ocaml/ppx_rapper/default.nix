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
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "roddyyaga";
    repo = "ppx_rapper";
    rev = "764f71a3b6b6f0416896efec5ef5bca352e5c81b";
    hash = "sha256-N+x620aYGPn3aXnDXuZURD6GpuPh/K1TvXCS+cicVXU=";
  };

  postPatch = lib.optionalString (lib.versionOlder ppxlib.version "0.36") ''
    substituteInPlace ppx/ppx_rapper.ml \
      --replace-fail "          ~constraint_:drop" ""
  '';

  buildInputs = [ ppxlib ];
  propagatedBuildInputs = [
    caqti
    pg_query
    base
  ];
}
