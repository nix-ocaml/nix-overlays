# `nixpkgs` here are the `nixpkgs` sources, i.e. the flake input
nixpkgs:

# This might be helfpul later:
# https://www.reddit.com/r/NixOS/comments/6hswg4/how_do_i_turn_an_overlay_into_a_proper_package_set/
final: prev:

let
  inherit (prev) lib stdenv fetchFromGitHub callPackage;
  overlayOCamlPackages = attrs: import ../ocaml/overlay-ocaml-packages.nix (attrs // {
    inherit nixpkgs;
  });
  staticLightExtend = pkgSet: pkgSet.extend (final: prev:
    prev.lib.overlayOCamlPackages {
      inherit prev;
      overlays = [ (prev.callPackage ../static/ocaml.nix { }) ];
      updateOCamlPackages = true;
    });

in

(overlayOCamlPackages {
  inherit prev;
  overlays = [ (callPackage ../ocaml { inherit nixpkgs; }) ];
}) // {
  # Cross-compilation / static overlays
  pkgsMusl = staticLightExtend prev.pkgsMusl;
  pkgsStatic = staticLightExtend prev.pkgsStatic;

  pkgsCross =
    let
      static-overlays = callPackage ../static { inherit (final) pkgsStatic; };
      cross-overlays = callPackage ../cross { };
    in
    prev.pkgsCross // {
      musl64 = prev.pkgsCross.musl64.appendOverlays static-overlays;

      aarch64-multiplatform =
        prev.pkgsCross.aarch64-multiplatform.appendOverlays cross-overlays;

      aarch64-multiplatform-musl =
        (prev.pkgsCross.aarch64-multiplatform-musl.appendOverlays
          (cross-overlays ++ static-overlays));
    };


  # Other packages

  # Stripped down postgres without the `bin` part, to allow static linking
  # with musl.
  libpq = (prev.postgresql_13.override {
    enableSystemd = false;
    gssSupport = false;
    openssl = final.openssl-oc;
  }).overrideAttrs (o: {
    doCheck = false;
  });

  opaline = prev.opaline.override { inherit (final) ocamlPackages; };
  esy = callPackage ../ocaml/esy { };

  ocamlformat = prev.ocamlformat.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace vendor/parse-wyc/menhir-recover/emitter.ml \
      --replace \
      "String.capitalize" "String.capitalize_ascii"
    '';
  });


  lib = lib.fix (final: lib //
  (import
    (builtins.fetchTarball {
      url = https://github.com/hercules-ci/gitignore.nix/archive/5b9e0ff9d3b551234b4f3eb3983744fa354b17f1.tar.gz;
      sha256 = "01l4phiqgw9xgaxr6jr456qmww6kzghqrnbc7aiiww3h6db5vw53";
    })
    { inherit lib; }) // {
    filterSource = { src, dirs ? [ ], files ? [ ] }: (final.cleanSourceWith {
      inherit src;
      # Good examples: https://github.com/NixOS/nixpkgs/blob/master/lib/sources.nix
      filter = name: type:
        let
          path = toString name;
          baseName = baseNameOf path;
          relPath = final.removePrefix (toString src + "/") path;
        in
        final.any (dir: dir == relPath || (final.hasPrefix "${dir}/" relPath)) dirs ||
        (type == "regular" && (final.any (file: file == baseName) files));
    });

    filterGitSource = args: final.gitignoreSource (final.filterSource args);

    inherit overlayOCamlPackages;
  });

  inherit (callPackage ../cockroachdb { })
    cockroachdb-21_1_x
    cockroachdb-21_2_x
    cockroachdb-22_x;
  cockroachdb = final.cockroachdb-21_1_x;

  pnpm = final.writeScriptBin "pnpm" ''
    #!${final.runtimeShell}
    ${final.nodejs_latest}/bin/node \
      ${final.nodePackages_latest.pnpm}/lib/node_modules/pnpm/bin/pnpm.cjs \
      "$@"
  '';
} // (
  lib.mapAttrs'
    (n: p: lib.nameValuePair "${n}-oc" p)
    {
      inherit (prev) zlib gmp libffi;
      openssl = prev.openssl_3_0;
    }
)
