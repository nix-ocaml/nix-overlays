# This might be helfpul later:
# https://www.reddit.com/r/NixOS/comments/6hswg4/how_do_i_turn_an_overlay_into_a_proper_package_set/
self: super:
let
  inherit (super) lib stdenv fetchFromGitHub callPackage;
  gitignoreNix = fetchFromGitHub {
    owner = "hercules-ci";
    repo = "gitignore.nix";
    rev = "00b237fb1813c48e20ee2021deb6f3f03843e9e4";
    sha256 = "186pvp1y5fid8mm8c7ycjzwzhv7i6s3hh33rbi05ggrs7r3as3yy";
  };

  gitignoreSource = (import gitignoreNix { inherit lib; }).gitignoreSource;

  overlayOcamlPackages = version: {
    "ocamlPackages_${version}" =
      super.ocaml-ng."ocamlPackages_${version}".overrideScope'
        (callPackage ./ocaml { });
  };
  ocamlVersions = [ "4_06" "4_08" "4_09" "4_10" "4_11" "4_12" ];
  oPs =
    lib.fold lib.mergeAttrs { }
      (builtins.map overlayOcamlPackages ocamlVersions);

in
{
  # Stripped down postgres without the `bin` part, to allow static linking
  # with musl
  libpq = super.postgresql.override { enableSystemd = false; };

  dot-merlin-reader = (super.dot-merlin-reader.override {
    inherit (self) ocamlPackages;
  }).overrideAttrs (_: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml/merlin/releases/download/v4.0-411/merlin-v4.0-411.tbz;
      sha256 = "0m7az1p6sf4fyy763z921j2q2ahl5zf83dgsmpcv29cnjy088655";
    };
  });

  ocamlPackages-bs = self.ocaml-ng.ocamlPackages_4_06.overrideScope' (oself: osuper: {
    ocaml = import ./bucklescript-experimental/ocaml.nix {
      inherit (super) lib stdenv;
      inherit (super.ocaml.meta) license;
      src = "${self.bucklescript-experimental.src}/ocaml";
      version = "4.06.1+BS";
    };
  });

  ocamlPackages = oPs.ocamlPackages_4_11;
  ocamlPackages_latest = self.ocamlPackages;
  opaline = (super.opaline.override {
    inherit (self) ocamlPackages;
  }).overrideAttrs (o: {
    nativeBuildInputs = o.buildInputs;
  });

  # 4.06, 4.09 and 4.10 treated specially out of convenience because:
  # - 4.09 is still used in some of my projects
  # - 4.10 is the latest stable version
  # - 4.06 is used by BuckleScript
  ocaml-ng = super.ocaml-ng // oPs // {
    ocamlPackages = self.ocamlPackages;
    ocamlPackages_multicore = (oPs.ocamlPackages_4_10.overrideScope' (oself: osuper: {
      ocaml = osuper.ocaml.overrideAttrs (_: {
        version = "4.10.0+multicore+no-effect-syntax";
        hardeningDisable = [ "strictoverflow" ];
        src = builtins.fetchurl {
          url = https://github.com/ocaml-multicore/ocaml-multicore/archive/eabff64f6d35507a9ebd9d649c159f73891bebbf.tar.gz;
          sha256 = "0mda1rzwf1hr4kx15q67g1awbihqrcky6zi96ps14jgk83didv4j";
        };
      });
    })).overrideScope' (callPackage ./ocaml { });
  };

  ocamlformat = super.ocamlformat.overrideAttrs (o: {
    src = builtins.fetchurl {
      url = https://github.com/ocaml-ppx/ocamlformat/releases/download/0.17.0/ocamlformat-0.17.0.tbz;
      sha256 = "0f1lxp697yq61z8gqxjjaqd2ns8fd1vjfggn55x0gh9dx098p138";
    };

    buildInputs = (lib.remove self.ocamlPackages.ocaml-migrate-parsetree-1-8 o.buildInputs) ++
      (with self.ocamlPackages; [ ppxlib dune-build-info ocaml-version ocaml-migrate-parsetree-2-1 ]);
  });

  # BuckleScript
  bs-platform = callPackage ./bs-platform {
    ocamlPackages = self.ocamlPackages-bs;
  };

  dune_2 =
    if lib.versionAtLeast self.ocamlPackages.ocaml.version "4.06"
    then self.ocamlPackages.dune_2
    else if lib.versionAtLeast self.ocamlPackages.ocaml.version "4.02"
    then self.ocaml-ng.ocamlPackages_4_11.dune_2
    else throw "dune_2 is not available for OCaml ${self.ocamlPackages.ocaml.version}";

  bucklescript-experimental = callPackage ./bucklescript-experimental {
    ocamlPackages = self.ocamlPackages-bs;
    dune_2 = self.ocamlPackages.dune_2;
  };

  pkgsCross = super.pkgsCross // {
    musl64 = super.pkgsCross.musl64.appendOverlays (callPackage ./static {
      inherit ocamlVersions;
    });

    aarch64-multiplatform = super.pkgsCross.aarch64-multiplatform.appendOverlays (callPackage ./cross {
      inherit ocamlVersions;
    });

    aarch64-multiplatform-musl =
      (super.pkgsCross.aarch64-multiplatform-musl.appendOverlays
        ((callPackage ./cross { inherit ocamlVersions; }) ++
          (callPackage ./static { inherit ocamlVersions; })));
  };


  # Other packages

  lib = super.lib // rec {
    inherit gitignoreSource;
    filterSource = { src, dirs ? [ ], files ? [ ] }: (super.lib.cleanSourceWith rec {
      inherit src;
      # Good examples: https://github.com/NixOS/nixpkgs/blob/master/lib/sources.nix
      filter = name: type:
        let
          path = toString name;
          baseName = baseNameOf path;
          relPath = lib.removePrefix (toString src + "/") path;
        in
        lib.any (dir: dir == relPath || (lib.hasPrefix "${dir}/" relPath)) dirs ||
          (type == "regular" && (lib.any (file: file == baseName) files));
    });
    filterGitSource = args: gitignoreSource (filterSource args);
  };

  cockroachdb = callPackage ./cockroachdb { };
}
