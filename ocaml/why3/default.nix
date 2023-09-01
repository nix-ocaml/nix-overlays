{ autoconf
, automake
, stdenv
, darwin
, ocaml
, findlib
, menhir
, coqPackages
, ocamlgraph
, zarith
, emacs
, rubber
, hevea
, lablgtk3-sourceview3
, js_of_ocaml
, js_of_ocaml-ppx
, ppx_deriving
, ppx_sexp_conv
, camlzip
, menhirLib
, num
, re
, sexplib
, nixpkgs
, callPackage
, lib
}:

stdenv.mkDerivation rec {
  pname = "why3";
  version = "1.6.0";

  src = builtins.fetchurl {
    url = "https://why3.gitlabpages.inria.fr/releases/${pname}-${version}.tar.gz";
    sha256 = "071734yr4ys89kla722v27n93l4pndbyk73hf2ns0wfj87mcqnw4";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    menhir
    # Coq Support
    coqPackages.coq
    autoconf
    automake
  ];

  buildInputs = [
    ocamlgraph
    zarith
    # Emacs compilation of why3.el
    emacs
    # Documentation
    rubber
    hevea
    # GUI
    lablgtk3-sourceview3
    # WebIDE
    js_of_ocaml
    js_of_ocaml-ppx
    # S-expression output for why3pp
    ppx_deriving
    ppx_sexp_conv
  ]
  # Coq Support
  ++ (with coqPackages; [ coq flocq ])
  ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [ AppKit ]);

  propagatedBuildInputs = [ camlzip menhirLib num re sexplib ];

  enableParallelBuilding = true;

  configureFlags = [ "--enable-verbose-make" ];

  installTargets = [ "install" "install-lib" ];

  passthru.withProvers = callPackage "${nixpkgs}/pkgs/applications/science/logic/why3/with-provers.nix" { };

  meta = with lib; {
    description = "A platform for deductive program verification";
    homepage = "https://why3.lri.fr/";
    license = licenses.lgpl21;
    platforms = platforms.unix;
    maintainers = with maintainers; [ thoughtpolice vbgl ];
  };
}
