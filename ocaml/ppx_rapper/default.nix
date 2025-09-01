{ fetchFromGitHub
, buildDunePackage
, base
, caqti
, pg_query
, lib
, ocaml
}:

buildDunePackage rec {
  pname = "ppx_rapper";
  version = "3.0.0";

  src =
    if lib.versionOlder "5.3" ocaml.version
    then
      fetchFromGitHub
        {
          owner = "roddyyaga";
          repo = "ppx_rapper";
          rev = "ac71881c7ef1c40c4996c0080365bf2f12d275d1";
          hash = "sha256-2XTpk1kUakxddcR7ZBiv4hynV6dznDy//G7914azJKU=";
        } else
      fetchFromGitHub {
        owner = "roddyyaga";
        repo = "ppx_rapper";
        rev = "5b0e62def2d5cc6cbe3dedec1ecb289bee350f9a";
        hash = "sha256-Fn13E8H5+ciEIF5wIA6qzEGX5GLe0SYz7i/TSdk1g1M=";
      };

  propagatedBuildInputs = [ caqti pg_query base ];
}
