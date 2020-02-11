{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDune2Package {
  pname = "ppx_rapper";
  version = "1.1.0-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ppx_rapper";
    rev = "693fc6c9e25017c814f2ebacbdb3be8a7614a9ad";
    sha256 = "053y3kgad80qrg1slfhf7qln8nbbrwfhspvbqxc4cxdgsad9c479";
  };

  propagatedBuildInputs = with ocamlPackages; [
    caqti
    caqti-lwt
    base
    pg_query
  ];
}
