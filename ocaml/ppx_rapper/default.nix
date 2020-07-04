{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "ppx_rapper";
  version = "1.1.0-dev";

  src = fetchFromGitHub {
    owner = "roddyyaga";
    repo = "ppx_rapper";
    rev = "1.2.0";
    sha256 = "0bpkw8krcmmrxbc1rala29r5l1vf5i00ma5rlr1sz07frg70dbp3";
  };

  useDune2 = true;

  propagatedBuildInputs = with ocamlPackages; [
    caqti
    caqti-lwt
    base
    pg_query
  ];
}
