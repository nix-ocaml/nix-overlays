{ stdenv, fetchFromGitHub, ocaml, findlib, camlp-streams, fmt, fix, perl }:

stdenv.mkDerivation
{
  pname = "camlp5";
  version = "8.00.04";
  src = fetchFromGitHub {
    owner = "camlp5";
    repo = "camlp5";
    rev = "rel8.00.04";
    sha256 = "sha256-U+EifChwxtAh2wn7MW1KTQex3a+QGQ3KOupHUlkdNVk=";
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
