{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "reason";
  version = "3.7.0";

  src = builtins.fetchurl {
    # https://github.com/reasonml/reason/pull/2657 -- OCaml 4.13 support
    url = https://github.com/reasonml/reason/archive/c2039caeedffd70f311aed9232bd368182983d9f.tar.gz;
    sha256 = "06vyqnyqs71l5npp6bipimscsvx00w578yk370b2sw44a2ai50df";
  };

  propagatedBuildInputs = [ menhir menhirLib menhirSdk fix merlin-extend ppx_derivers result ];

  buildInputs = [ cppo menhir ];

  patches = [
    ./patches/0001-rename-labels.patch
  ];
}
