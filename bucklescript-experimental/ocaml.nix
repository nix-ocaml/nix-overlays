{ stdenv, lib, src, version, license }:

stdenv.mkDerivation rec {
  inherit src version;
  name = "ocaml-${version}";

  configurePhase = ''
    ./configure --prefix $out --enable-flambda
  '';

  preBuild = ''
    make clean
  '';

  buildFlags = [ "-j16" "world.opt" ];

  meta = with lib; {
    branch = "4.12";
    platforms = platforms.all;
    inherit license;
  };
}
