{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "ppx_rapper";
  version = "1.1.0-dev";

  src = fetchFromGitHub {
    owner = "roddyyaga";
    repo = "ppx_rapper";
    rev = "a486188d0431dab205abc05f4f7e34d947332248";
    sha256 = "1zhq4a2ymdsvri31dxjnbg9pj92347y07j6a7pbd6kryrp5gg5g0";
  };

  useDune2 = true;

  propagatedBuildInputs = with ocamlPackages; [
    caqti
    caqti-lwt
    base
    pg_query
  ];
}
