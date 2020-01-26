{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDune2Package {
  pname = "ppx_rapper";
  version = "0.9.3-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ppx_rapper";
    rev = "5acca0f23a03e3d3107881c354c6b2a48df219d9";
    sha256 = "0jw31pirxqarqh6fnn1njhr2p1xky8lji4w5kxb0srprlvvyk78n";
  };

  propagatedBuildInputs = with ocamlPackages; [
    caqti
    base
    pg_query
  ];
}
