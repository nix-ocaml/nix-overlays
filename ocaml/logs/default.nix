{ lib
, ocamlPackages
, stdenv
, jsooSupport ? true
}:

with ocamlPackages;

let
  pname = "logs";
  webpage = "https://erratique.ch/software/${pname}";
in

stdenv.mkDerivation rec {
  name = "ocaml${ocaml.version}-${pname}-${version}";
  version = "0.7.0";

  src = builtins.fetchurl {
    url = "${webpage}/releases/${pname}-${version}.tbz";
    sha256 = "1jnmd675wmsmdwyb5mx5b0ac66g4c6gpv5s4mrx2j6pb0wla1x46";
  };

  nativeBuildInputs = [ ocaml findlib ocamlbuild ];
  buildInputs = [ findlib topkg fmt cmdliner lwt ]
    ++ lib.optional jsooSupport js_of_ocaml;
  propagatedBuildInputs = [ result ];

  buildPhase = "${topkg.run} build --with-js_of_ocaml ${lib.boolToString jsooSupport}";

  inherit (topkg) installPhase;
}
