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

{ callPackage, bash, binutils, coreutils, makeWrapper, lib, fetchFromGitHub, fetchFromGitLab, ocamlPackages }:

let
  currentVersion = "0.6.12";

  githubInfo = {
    owner = "esy";
    rev = "v${currentVersion}";
    sha256 = "sha256-W3GZ088rju3xAa4/y0sY/Zp2UWJqbF2Ke9oMDSPv598=";
  };

  esyVersion = currentVersion;

  esyOcamlPkgs = ocamlPackages.overrideScope' (self: super: rec {
    # buildDunePackage = (super.buildDunePackage.override { dune_1 = super.dune_one; });

    cmdliner =
      super.cmdliner.overrideAttrs (_: {
        src = builtins.fetchurl {
          url = https://github.com/esy-ocaml/cmdliner/archive/e9316bc.tar.gz;
          sha256 = "1g0shk5ahc6byhx79ry6vdyf89a1ncq5bsgykkxa05xabvlr09ji";
        };
        createFindlibDestdir = true;
      });

    menhirLib = super.menhirLib.overrideAttrs (_: {
      version = "20211012";
      src = fetchFromGitLab {
        domain = "gitlab.inria.fr";
        owner = "fpottier";
        repo = "menhir";
        rev = "20211012";
        sha256 = "sha256-gHw9LmA4xudm6iNPpop4VDi988ge4pHZFLaEva4qbiI=";
      };
    });
  });
in

with esyOcamlPkgs;

let
  esy-solve-cudf = buildDunePackage rec {
    pname = "esy-solve-cudf";
    version = "0.1.10";
    buildInputs = [
      ocaml
      findlib
      dune
    ];
    propagatedBuildInputs = [
      cmdliner
      cudf
      mccs
      ocaml_extlib
    ];
    src = fetchFromGitHub {
      owner = "andreypopp";
      repo = pname;
      rev = "v${version}";
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
    sha256 = "0v43x5s34fsw70zgi9zvfpmjakkbfxpzc6zy0a70bzw293qvy7i0";
  };

  esySolveCudfNpm = builtins.fetchurl {
    url = "https://registry.npmjs.org/esy-solve-cudf/${esy-solve-cudf.version}";
    sha256 = "19m793mydd8gcgw1mbn7pd8fw2rhnd00k5wpa4qkx8a3zn6crjjf";
  };

in

buildDunePackage {
  pname = "esy";
  version = esyVersion;

  minimumOCamlVersion = "4.06";

  src = fetchFromGitHub {
    owner = githubInfo.owner;
    repo = "esy";
    rev = githubInfo.rev;
    sha256 = githubInfo.sha256;
  };

  nativeBuildInputs = [
    makeWrapper
    dune-configurator
  ];

  propagatedBuildInputs = [
    coreutils
    bash
  ];

  buildInputs = [
    angstrom
    cmdliner
    reason
    bos
    fmt
    fpath
    lambda-term
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
    dune build -p esy
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
  postInstall = ''
    mkdir -p $out/lib/default/bin
    mkdir -p $out/lib/default/esy-build-package/bin
    mkdir -p $out/lib/node_modules/esy-solve-cudf
    mkdir -p $out/lib/esy
    # mv $out/bin/esyInstallRelease.js $out/lib/default/bin/
    cp ${esyNpm} $out/package.json
    # cp ${esySolveCudfNpm} $out/lib/node_modules/esy-solve-cudf/package.json
    ln -s ${esy-solve-cudf}/bin/esy-solve-cudf $out/lib/esy/esySolveCudfCommand
    ls $out/lib/esy


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
