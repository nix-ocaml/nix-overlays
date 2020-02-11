{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDune2Package {
  pname = "ppx_rapper";
  version = "1.1.0-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ppx_rapper";
    rev = "482791f0127c9d6ae7e4f8db397e9661386fa9d2";
    sha256 = "0gy6bygywd56rciq3wv5v9faq0b2rai43rwz22g448wdkv99z8w6";
  };

  propagatedBuildInputs = with ocamlPackages; [
    caqti
    caqti-lwt
    base
    pg_query
  ];
}
