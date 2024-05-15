{ stdenv
, fetchFromGitHub
, ocaml
, findlib
, camlp-streams
, fmt
, fix
, lib
, perl
, bos
, ocaml_pcre
, re
, rresult
}:

stdenv.mkDerivation
{
  pname = "camlp5";
  version = "8.02.00";

  src = fetchFromGitHub {
    owner = "camlp5";
    repo = "camlp5";
    rev = "8.03.00";
    hash = "sha256-hu/279gBvUc7Z4jM6EHiar6Wm4vjkGXl+7bxowj+vlM=";
  };

  nativeBuildInputs = [ ocaml findlib ];
  buildInputs = [ perl ];
  propagatedBuildInputs = [
    bos
    camlp-streams
    fmt
    fix
    ocaml_pcre
    re
    rresult
  ];

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
