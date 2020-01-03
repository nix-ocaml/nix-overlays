{ fetchFromGitHub, stdenv, ocamlPackages }:

with ocamlPackages;

let opam-lib = { pname, deps }: stdenv.mkDerivation {
  name = pname;
  version = "2.0.5";
  buildInputs = [ ocaml findlib dune ];
  propagatedBuildInputs = deps;
  src = fetchFromGitHub {
    owner  = "ocaml";
    repo   = "opam";
    rev    = "${version}";
    sha256 = "0pf2smq2sdcxryq5i87hz3dv05pb3zasb1is3kxq1pi1s4cn55mx";
  };
  configurePhase = ''
      ./configure --disable-checks
  '';
  buildPhase = ''
      make ${name}.install
  '';
  installPhase = ''
      runHook preInstall
      ${opaline}/bin/opaline -prefix $out -libdir $OCAMLFIND_DESTDIR
      runHook postInstall
  '';
};
in rec {
  opam-core = opam-lib {
    pname= "opam-core";
    deps = [ ocamlgraph re cppo ];
  };

  opam-format = opam-lib {
    pname = "opam-format";
    deps = [ opam-file-format opam-core ];
  };

  opam-repository = opam-lib {
    pname = "opam-repository";
    deps = [ opam-format ];
  };

  opam-state = opam-lib {
    pname = "opam-state";
    deps = [ opam-repository ];
  };
}

