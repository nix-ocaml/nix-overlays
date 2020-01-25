{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDune2Package {
  pname = "ppx_rapper";
  version = "0.9.3-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ppx_rapper";
    rev = "37cc25540e39a447fdef675106849b6e23b63f11";
    sha256 = "1gpgpi2apvpnza29sdd14zxy5dljgg1n2khxz2nsl5l0wiwms5zn";
  };

  propagatedBuildInputs = with ocamlPackages; [
    caqti
    base
    pg_query
  ];
}
