{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDune2Package {
  pname = "ppx_rapper";
  version = "0.9.3-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ppx_rapper";
    rev = "ab3feb1a1ae0dca7e002faf91ccfb1b55c504853";
    sha256 = "1k80k1vkrryziva91h8kz2bi427fv5gdfl0bw6ajkypy7hi6s56b";
  };

  propagatedBuildInputs = with ocamlPackages; [
    caqti
    base
    pg_query
  ];
}
