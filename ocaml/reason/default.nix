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
          url = https://github.com/reasonml/reason/archive/9b459245de02b89a27100d34209a819dd9921de2.tar.gz;
          sha256 = "03i33i32ljzbqfmgahcp7x35v0p4983q0hsmbryj1jkndvzlad4f";
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
