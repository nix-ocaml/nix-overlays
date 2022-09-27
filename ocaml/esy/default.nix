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
    alcotest = super.alcotest.overrideAttrs (_: {
      src = builtins.fetchurl {
        url = https://github.com/mirage/alcotest/releases/download/1.4.0/alcotest-mirage-1.4.0.tbz;
        sha256 = "1h9yp44snb6sgm5g1x3wg4gwjscic7i56jf0j8jr07355pxwrami";
      };
      propagatedBuildInputs = with self; [
        astring
        cmdliner
        fmt
        uuidm
        re
        stdlib-shims
        uutf
      ];
    });

    cmdliner =
      super.cmdliner.overrideAttrs (_: {
        src = builtins.fetchurl {
          url = https://github.com/esy-ocaml/cmdliner/archive/e9316bc.tar.gz;
          sha256 = "1g0shk5ahc6byhx79ry6vdyf89a1ncq5bsgykkxa05xabvlr09ji";
        };
        createFindlibDestdir = true;
      });

    fmt = super.fmt.overrideAttrs (_: {
      src = builtins.fetchurl {
        url = https://github.com/dbuenzli/fmt/archive/refs/tags/v0.8.10.tar.gz;
        sha256 = "0xnnrhp45p5vj1wzjn39w0j29blxrqj2dn42qcxzplp2j9mn76b9";
      };
    });

    uuidm = super.uuidm.overrideAttrs (_: {
      src = builtins.fetchurl {
        url = "https://erratique.ch/software/uuidm/releases/uuidm-0.9.7.tbz";
        sha256 = "1ivxb3hxn9bk62rmixx6px4fvn52s4yr1bpla7rgkcn8981v45r8";
      };

    });

    uunf = super.uunf.override { cmdlinerSupport = false; };
    uuseg = super.uuseg.override { cmdlinerSupport = false; };

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
    sha256 = "09b2543pm3bwj0lq7i1xk51rb9h5j9rmv8hl96krwnl2kzxa7ymq";
  };

  esySolveCudfNpm = builtins.fetchurl {
    url = "https://registry.npmjs.org/esy-solve-cudf/${esy-solve-cudf.version}";
    sha256 = "001c4m10z4y9bfn5gllqdh7irlj64w7n9d10q43802myl92hpkzs";
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
