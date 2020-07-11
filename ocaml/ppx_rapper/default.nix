{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "ppx_rapper";
  version = "1.1.0-dev";

  src = fetchFromGitHub {
    owner = "roddyyaga";
    repo = "ppx_rapper";
    rev = "2.0.0";
    sha256 = "07y9qyh2mdk5bmxjm2jacpb5a2q1pwnykjlpz3z630h0sahspwp5";
  };

  useDune2 = true;

  propagatedBuildInputs = with ocamlPackages; [
    caqti
    caqti-lwt
    base
    pg_query
  ];
}
