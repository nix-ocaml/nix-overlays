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

  src =
    if (lib.versionOlder "5.2" ocaml.version) then
      fetchFromGitHub
        {
          owner = "camlp5";
          repo = "camlp5";
          rev = "cb6b1bb389a5e9c3915da1bcb8c3ce7f4fd91452";
          hash = "sha256-SUgjGhm3mjnYe7jO80A9VxA5bWAu1ptwgttlZC5oF4k=";
        } else
      fetchFromGitHub {
        owner = "camlp5";
        repo = "camlp5";
        rev = "8.02.00";
        hash = "sha256-No+rTEJEHaaPVV8BSPeuDDOiNd58DF+YArz+h2hxvaM=";
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
