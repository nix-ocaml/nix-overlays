{ opaline, stdenv, ocamlPackages }:

with ocamlPackages;

let opam-lib = { pname, deps }: stdenv.mkDerivation rec {
  name = pname;
  version = "2.0.7";
  buildInputs = [ ocaml findlib dune ];
  propagatedBuildInputs = deps;
  src = builtins.fetchurl {
    url  = "https://github.com/ocaml/opam/archive/${version}.tar.gz";
    sha256 = "15b5c8f5hnhx8s4gcxfy509vv4r15wv2z5ds1p2gsqfdhwr8zwa2";
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
in {
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

