{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDune2Package {
  pname = "ppx_rapper";
  version = "0.9.3-dev";

  src = fetchFromGitHub {
    owner = "roddyyaga";
    repo = "ppx_rapper";
    rev = "1.0.2";
    sha256 = "0w8dnvz8dvvngd17liq97w4f557djrm1i0jfzq05fmydq7sckfpf";
  };

  propagatedBuildInputs = with ocamlPackages; [
    caqti
    caqti-lwt
    base
    pg_query
  ];
}
