{ stdenv, lib, license }:

stdenv.mkDerivation rec {
  src = builtins.fetchurl {
    url = https://github.com/melange-re/ocaml/archive/75f22c8.tar.gz;
    sha256 = "1j3ydjpd7wrwl55mgcc30wrvj2vmppas067c90wkqnmy8wmv5isi";
  };
  version = "4.12.0+BS";
  name = "ocaml-${version}";

  configurePhase = ''
    ./configure --prefix $out --enable-flambda
  '';

  preBuild = ''
    make clean
  '';

  buildFlags = [ "-j16" "world.opt" ];

  meta = with lib; {
    branch = "4.12.0+BS";
    platforms = platforms.all;
    inherit license;
  };
}
