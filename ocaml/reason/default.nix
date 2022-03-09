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
        url = "https://github.com/reasonml/reason/releases/download/${version}/reason-${version}.tbz";
        sha256 = "0yc94m3ddk599crg33yxvkphxpy54kmdsl599c320wvn055p4y4l";
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
