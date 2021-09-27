{ ocamlPackages, lib }:

with ocamlPackages;

buildDunePackage {
  pname = "reason";
  version = "3.7.0";

  src =
    if (lib.versionOlder "4.13" ocaml.version) then
      builtins.fetchurl
        {
          # https://github.com/reasonml/reason/pull/2657 -- OCaml 4.13 support
          url = https://github.com/reasonml/reason/archive/b6d8bff0.tar.gz;
          sha256 = "08jvbaql7a0mpmpwyzndjsl2403wk545nqhw80ba02r5r4wg297p";
        } else
      builtins.fetchurl {
        url = https://registry.npmjs.org/@esy-ocaml/reason/-/reason-3.7.0.tgz;
        sha256 = "0spqbsphxnpp3jdy4amfgw58w6mam5gb4vn9gxm5nh9rkcz0iaqg";
      };


  propagatedBuildInputs = [ menhir menhirLib menhirSdk fix merlin-extend ppx_derivers result ];

  buildInputs = [ cppo menhir ];

  patches = [
    ./patches/0001-rename-labels.patch
  ];
}
