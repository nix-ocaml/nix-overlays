# nix-build -E  \
#   'with import <nixpkgs> { };
#    let esy = callPackage ./nix/esy {};
#    in
#    callPackage esy {
#      githubInfo = {
#        owner = "anmonteiro";
#        rev= "42291a9";
#        sha256="0mpjlbplhwgnhd12hykh1m5pjqsclax24dywhyl2nsgqlwchghs3";
#      };
#    }' \
#  --pure

{ callPackage, bash, binutils, coreutils, makeWrapper, lib, fetchFromGitHub, ocamlPackages }:

let
  currentVersion = "0.6.11";

  githubInfo = {
    owner = "esy";
    rev = "v${currentVersion}";
    sha256 = "sha256-LEfhtz0dBObE+167toMp1mz5onMbp7h2RVB+RgtbahM=";
  };

  esyVersion = currentVersion;

  esyOcamlPkgs = ocamlPackages.overrideScope' (self: super: {
    # buildDunePackage = (super.buildDunePackage.override { dune_1 = super.dune_one; });

    cmdliner =
      super.cmdliner.overrideAttrs (_: {
        src = builtins.fetchurl {
          url = https://github.com/esy-ocaml/cmdliner/archive/e9316bc.tar.gz;
          sha256 = "1g0shk5ahc6byhx79ry6vdyf89a1ncq5bsgykkxa05xabvlr09ji";
        };
        createFindlibDestdir = true;
      });
  });

  esy-solve-cudf = esyOcamlPkgs.buildDunePackage rec {
    pname = "esy-solve-cudf";
    version = "0.1.10";
    buildInputs = with esyOcamlPkgs; [
      ocaml
      findlib
      dune
    ];
    propagatedBuildInputs = with esyOcamlPkgs; [
      cmdliner
      cudf
      mccs
      ocaml_extlib
    ];
    src = fetchFromGitHub {
      owner = "andreypopp";
      repo = pname;
      rev = "v${version}";
      # sha256 = "174q1wkr31dn8vsvnlj4hzfgvbamqq74n7wxhbccriqmv8lz5a3g";
      sha256 = "1ky2mkyl676bxphyx0d3vqr58za185nq46h0lai89631g94ia1d7";
    };

    buildPhase = ''
      runHook preBuild
      dune build -p ${pname}
      runHook postBuild
    '';

    meta = {
      homepage = https://github.com/andreypopp/esy-solve-cudf;
      description = "package.json workflow for native development with Reason/OCaml";
      license = lib.licenses.gpl3;
    };
  };

  # XXX(anmonteiro): The NPM registry doesn't allow us to fetch version
  # information for scoped packages, and `@esy-nightly/esy` is scoped. It also
  # seems that Esy only uses the `package.json` file to display the version
  # information in `esy --version`, so we can kinda ignore this for now. We're
  # able to build and install nightly releases but it'll always display the
  # current version information.
  esyNpm = builtins.fetchurl {
    url = "https://registry.npmjs.org/esy/${esyVersion}";
    sha256 = "1gnd2saq969nxrxfks257n0hp5s4ywh9r91hwgwyg9misgivd3m7";
  };

  esySolveCudfNpm = builtins.fetchurl {
    url = "https://registry.npmjs.org/esy-solve-cudf/${esy-solve-cudf.version}";
    sha256 = "19m793mydd8gcgw1mbn7pd8fw2rhnd00k5wpa4qkx8a3zn6crjjf";
  };

in
esyOcamlPkgs.buildDunePackage rec {
  pname = "esy";
  version = esyVersion;

  minimumOCamlVersion = "4.06";

  src = fetchFromGitHub {
    owner = githubInfo.owner;
    repo = pname;
    rev = githubInfo.rev;
    sha256 = githubInfo.sha256;
  };

  nativeBuildInputs = with esyOcamlPkgs; [
    makeWrapper
    dune-configurator
  ];

  propagatedBuildInputs = [
    coreutils
    bash
  ];

  buildInputs = with esyOcamlPkgs; [
    angstrom
    cmdliner
    reason
    bos
    fmt
    fpath
    lambdaTerm
    logs
    lwt
    lwt_ppx
    menhir
    opam-file-format
    ppx_deriving
    ppx_deriving_yojson
    ppx_expect
    ppx_inline_test
    ppx_let
    ppx_sexp_conv
    re
    yojson
    cudf
    dose3
    opam-format
    opam-core
    opam-state
  ];
  doCheck = false;

  buildPhase = ''
    runHook preBuild
    dune build -p ${pname}
    runHook postBuild
  '';

  # |- bin
  #   |- esy
  # |- lib
  #   |- default
  #     |- bin
  #       |- esy.exe
  #       |- esyInstallRelease.js
  #     |- esy-build-package
  #       |- bin
  #       |- esyBuildPackageCommand.exe
  #       |- esyRewritePrefixCommand.exe
  #   |- node_modules
  #     |- esy-solve-cudf
  #       |- package.json
  #       |- esySolveCudfCommand.exe
  fixupPhase = ''
    mkdir -p $out/lib/default/bin
    mkdir -p $out/lib/default/esy-build-package/bin
    mkdir -p $out/lib/node_modules/esy-solve-cudf
    mv $out/bin/esy $out/lib/default/bin/esy.exe
    mv $out/bin/esyInstallRelease.js $out/lib/default/bin/
    # mv $out/bin/esy-build-package $out/lib/default/esy-build-package/bin/esyBuildPackageCommand.exe
    # mv $out/bin/esy-rewrite-prefix $out/lib/default/esy-build-package/bin/esyRewritePrefixCommand.exe
    ln -s $out/lib/default/bin/esy.exe $out/bin/esy
    cp ${esyNpm} $out/package.json
    cp ${esySolveCudfNpm} $out/lib/node_modules/esy-solve-cudf/package.json
    cp ${esy-solve-cudf}/bin/esy-solve-cudf $out/lib/node_modules/esy-solve-cudf/esySolveCudfCommand.exe

    # wrapProgram \
      # $out/bin/esy \
      # --set ESY__GLOBAL_PATH /usr/bin:${binutils}/bin:${coreutils}/bin:${bash}/bin
  '';

  meta = {
    homepage = https://github.com/esy/esy;
    description = "package.json workflow for native development with Reason/OCaml";
    license = lib.licenses.bsd2;
  };
}
