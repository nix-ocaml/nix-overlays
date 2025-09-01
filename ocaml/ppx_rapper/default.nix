{ fetchFromGitHub, buildDunePackage, base, caqti, pg_query }:

buildDunePackage rec {
  pname = "ppx_rapper";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "roddyyaga";
    repo = "ppx_rapper";
    rev = "ac71881c7ef1c40c4996c0080365bf2f12d275d1";
    hash = "sha256-2XTpk1kUakxddcR7ZBiv4hynV6dznDy//G7914azJKU=";
  };

  propagatedBuildInputs = [ caqti pg_query base ];
}
