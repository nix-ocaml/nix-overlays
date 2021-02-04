{ stdenv, lib, src, version }:

stdenv.mkDerivation rec {
  inherit src version;
  name = "ocaml-${version}";

  configurePhase = ''
    ./configure -prefix $out -no-ocamlbuild  -no-curses -no-graph -no-debugger
  '';

  preBuild = ''
    make clean
  '';

  buildFlags = [ "-j9" "world.opt" ];

  meta = with lib; {
    branch = "4.06";
    platforms = platforms.all;
  };
}
