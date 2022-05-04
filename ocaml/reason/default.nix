{ lib
, buildDunePackage
, ocaml
, cppo
, menhir
, menhirLib
, menhirSdk
, fix
, merlin-extend
, ppx_derivers
, result
}:

buildDunePackage rec {
  pname = "reason";
  version = "3.8.0";

  src =
    if lib.versionOlder "5.00" ocaml.version
    then
      builtins.fetchurl
        {
          url = https://github.com/reasonml/reason/archive/64689cb65951cd30d13b8c63a21ed956834ee26a.tar.gz;
          sha256 = "00whcci10yf7hkbzksakr92zna351229c7cqabp3sm87h4hzfhzc";
        }
    else
      builtins.fetchurl {
        url = https://github.com/reasonml/reason/archive/4f6ff7616bfa699059d642a3d16d8905d83555f6.tar.gz;
        sha256 = "14x34hh0dkjgzv23vn88kay3y2hqjqyw2y4lyiv65qg7kf7z1gq1";
      };

  propagatedBuildInputs = [
    menhir
    menhirLib
    menhirSdk
    fix
    merlin-extend
    ppx_derivers
    result
  ];

  nativeBuildInputs = [ cppo menhir ];

  useDune2 = true;
  patches = [
    ./patches/0001-rename-labels.patch
  ];
}
