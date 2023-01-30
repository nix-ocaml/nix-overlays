{ stdenv, ocaml, findlib, camlp-streams, fmt, fix, perl }:

stdenv.mkDerivation
{
  pname = "camlp5";
  version = "8.00.04";
  src = builtins.fetchurl {
    url = https://github.com/camlp5/camlp5/archive/refs/tags/rel8.00.04.tar.gz;
    sha256 = "0w31lyzw38sxx10iqcjyka3r8m6w49268dh99dckly3vzh53a27s";
  };

  nativeBuildInputs = [ ocaml findlib ];
  buildInputs = [ perl ];
  propagatedBuildInputs = [ camlp-streams fmt fix ];

  prefixKey = "-prefix ";
  postPatch = ''
    patchShebangs ./etc/META.pl
  '';
  preConfigure = ''
    configureFlagsArray=(--strict --libdir $out/lib/ocaml/${ocaml.version}/site-lib)
    patchShebangs ./config/find_stuffversion.pl
  '';

  buildFlags = [ "world.opt" ];

  dontStrip = true;
}
