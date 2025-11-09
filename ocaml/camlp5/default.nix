{ lib
, stdenv
, fetchFromGitHub
, ocaml
, findlib
, perl
, makeWrapper
, rresult
, bos
, pcre2
, re
, camlp-streams
}:

let
  params =
    if lib.versionAtLeast ocaml.version "5.4" then rec {
      version = "8.04.00";

      src = fetchFromGitHub {
        owner = "camlp5";
        repo = "camlp5";
        rev = version;
        hash = "sha256-5IQVGm/tqEzXmZmSYGbGqX+KN9nQLQgw+sBP+F2keXo=";
      };
    } else rec {
      version = "8.03.02";

      src = fetchFromGitHub {
        owner = "camlp5";
        repo = "camlp5";
        rev = version;
        hash = "sha256-nz+VfGR/6FdBvMzPPpVpviAXXBWNqM3Ora96Yzx964o=";
      };
    };
in

stdenv.mkDerivation {
  pname = "ocaml${ocaml.version}-camlp5";
  inherit (params) src version;

  strictDeps = true;

  prefixKey = "-prefix ";

  preConfigure = ''
    configureFlagsArray=(--strict --libdir $out/lib/ocaml/${ocaml.version}/site-lib)
    patchShebangs ./config/find_stuffversion.pl etc/META.pl
  '';

  buildFlags = [ "world.opt" ];

  dontStrip = true;

  nativeBuildInputs = [
    makeWrapper
    ocaml
    findlib
    perl
  ];

  buildInputs = [
    bos
    pcre2
    re
    rresult
  ];

  propagatedBuildInputs = [ camlp-streams ];

  postInstall = ''
    for prog in camlp5 camlp5o camlp5r camlp5sch mkcamlp5 ocpp5
    do
      wrapProgram $out/bin/$prog \
        --prefix CAML_LD_LIBRARY_PATH : "$CAML_LD_LIBRARY_PATH"
    done
  '';

  meta = with lib; {
    description = "Preprocessor-pretty-printer for OCaml";
    longDescription = ''
      Camlp5 is a preprocessor and pretty-printer for OCaml programs.
      It also provides parsing and printing tools.
    '';
    homepage = "https://camlp5.github.io/";
    license = licenses.bsd3;
    platforms = ocaml.meta.platforms or [ ];
    maintainers = with maintainers; [
      maggesi
      vbgl
    ];
  };
}
