{ lib, fetchzip, stdenv, pkgs, opaline, ocamlPackages }:

with ocamlPackages;

let
  src = fetchzip {
    url = https://gitlab.com/tezos/tezos-rust-libs/-/archive/1f196947ab783d270ff41db2860ee76515c58608/tezos-rust-libs-1f196947ab783d270ff41db2860ee76515c58608.zip;
    sha256 = "0rf6y8pa6fipsyfww6hd9phy7c14d8lk1gcmf477hpkxjpb00cvs";
  };
  name = "tezos-rust-libs";
in

ocamlPackages.buildDunePackage {
  pname = name;
  version = "2.0-dev";
  inherit src;

  buildInputs = with ocamlPackages; [
    topkg
    findlib
  ];

  propagatedBuildInputs = [ pkgs.cargo pkgs.rustc ];

  buildPhase = ''
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
