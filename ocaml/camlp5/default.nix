{ stdenv, ocaml, findlib, camlp-streams, fmt, fix, perl }:

stdenv.mkDerivation
{
  pname = "camlp5";
  version = "8.00.04";
  src = builtins.fetchurl {
    url = https://github.com/camlp5/camlp5/archive/refs/tags/rel8.00.04.tar.gz;
    sha256 = "07bbjlljmj35g8d24s5c4m6rigivdvjbdpy4c6d0qh9d7ifcpnxx";
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
