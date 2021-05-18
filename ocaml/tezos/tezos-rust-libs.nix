{ lib, fetchzip, stdenv, pkgs, opaline, ocamlPackages }:

with ocamlPackages;

let
  src = fetchzip {
    url = https://gitlab.com/tezos/tezos-rust-libs/-/archive/v1.1/tezos-rust-libs-v1.1.zip;
    sha256 = "08wpcq6cbdvxdhazcpqzz4pywagy3fdbys07q2anbk6lq45rc2w6";
  };
  name = "tezos-rust-libs";
in

ocamlPackages.buildDunePackage {
  pname = name;
  version = "1.1";
  inherit src;

  buildInputs = with ocamlPackages; [
    topkg
    findlib
  ];

  propagatedBuildInputs = [ pkgs.cargo pkgs.rustc ];

  buildPhase = ''
    mkdir .cargo
    mv cargo-config .cargo/config
    cargo build --target-dir target --release
  '';

  installPhase = ''
    ${opaline}/bin/opaline -prefix $out -libdir $OCAMLFIND_DESTDIR/lib -name ${name}
  '';

  meta = {
    description = "Tezos: all rust dependencies and their dependencies";
    license = lib.licenses.mit;
  };

  createFindlibDestdir = true;
}
