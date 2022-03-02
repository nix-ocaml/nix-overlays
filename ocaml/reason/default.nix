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

buildDunePackage {
  pname = "reason";
  version = "3.7.0";

  src =
    if (lib.versionOlder "4.13" ocaml.version)
    then
      builtins.fetchurl
        {
          url = https://github.com/EduardoRFS/reason/archive/70984e94eae3084e56d0cfdf7d5d3be1ecda7b18.tar.gz;
          sha256 = "00m0az1r7zcfjsy312lr7xyk244f511llxbj8y2kiv4n1hx2fsar";
        } else 
    # Melange depends on the 4.08 AST, and until that's fixed we use this Reason version
      builtins.fetchurl {
        url = https://registry.npmjs.org/@esy-ocaml/reason/-/reason-3.7.0.tgz;
        sha256 = "0spqbsphxnpp3jdy4amfgw58w6mam5gb4vn9gxm5nh9rkcz0iaqg";
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
