{ stdenv, ocaml, findlib, camlp-streams, fmt, fix, perl }:

stdenv.mkDerivation
{
  pname = "camlp5";
  version = "7.14";
  src = builtins.fetchurl {
    url = https://github.com/camlp5/camlp5/archive/610c5f3.tar.gz;
    sha256 = "0p2w37r3scf5drv179s99nrygvr1rfa5cm84rgfypmjgg90h3n8m";
  };

  nativeBuildInputs = [ ocaml findlib ];
  buildInputs = [ perl ];
  propagatedBuildInputs = [ camlp-streams fmt fix ];

  prefixKey = "-prefix ";
  postPatch = ''
    cp -r ./ocaml_stuff/4.14.0 ./ocaml_stuff/5.0.0
    cp ./ocaml_src/lib/versdep/4.14.0.ml ./ocaml_src/lib/versdep/5.0.0.ml
    substituteInPlace odyl/odyl.ml --replace "Printexc.catch" ""
    substituteInPlace ocaml_src/odyl/odyl.ml --replace "Printexc.catch" ""
    patchShebangs ./etc/META.pl
  '';
  preConfigure = ''
    configureFlagsArray=(--strict --libdir $out/lib/ocaml/${ocaml.version}/site-lib)
    patchShebangs ./config/find_stuffversion.pl
  '';

  buildFlags = [ "world.opt" ];

  dontStrip = true;
}
