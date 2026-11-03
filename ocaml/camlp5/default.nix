{
  lib,
  stdenv,
  fetchFromGitHub,
  ocaml,
  findlib,
  perl,
  makeWrapper,
  rresult,
  bos,
  pcre2,
  re,
  camlp-streams,
}:

stdenv.mkDerivation rec {
  pname = "ocaml${ocaml.version}-camlp5";
  version = "8.05.03";
  src = fetchFromGitHub {
    owner = "camlp5";
    repo = "camlp5";
    tag = version;
    hash = "sha256-NzlNX5AYP/BgDowQj65aZUlGrJACrV05GUUIblxRdu0=";
  };

  strictDeps = true;

  prefixKey = "-prefix ";

  preConfigure = ''
    configureFlagsArray=(--strict --libdir $out/lib/ocaml/${ocaml.version}/site-lib)
    patchShebangs \
      ./config/find_stuffversion.pl etc/META.pl \
      tools/camlp5_comm.sh ocaml_src/tools/camlp5_comm.sh \
      ocaml_src/tools/ocamlc.sh ocaml_src/tools/ocamlopt.sh \
      tools/apply.sh tools/conv.sh tools/depend.sh tools/ocamlc.sh \
      tools/ocamlopt.sh compile/compile.sh configure etc/mkcamlp5.opt.sh.tpl \
      main/mkreloc.sh meta/mk_q_MLast.sh meta/mk_q_ast.sh
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
