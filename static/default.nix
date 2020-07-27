# Adapted from https://github.com/serokell/tezos-packaging/blob/b7617f99/nix/static.nix

{ pkgsPath ? <nixpkgs>, ocamlVersion ? "4_10" }:

let
  pkgsNative = import pkgsPath {};
  inherit (pkgsNative) lib;
  fixOCaml = ocaml:
    ((ocaml.override { useX11 = false; }).overrideAttrs (o: {
      configurePlatforms = [ ];
      dontUpdateAutotoolsGnuConfigScripts = true;
    })).overrideDerivation(o: {
      preConfigure = ''
          configureFlagsArray+=("CC=$CC" "PARTIALLD=$LD -r" "ASPP=$CC -c" "AS=$AS" "LIBS=-static")
      '';
        configureFlags = [
          "--enable-static"
          "-host ${o.stdenv.hostPlatform.config}"
          "-target ${o.stdenv.targetPlatform.config}"
        ];
      });
in
  import pkgsPath {
    crossSystem = lib.systems.examples.musl64;
    overlays =
      [ (import ../.) ] ++ (import ./overlays.nix {
        inherit pkgsNative lib fixOCaml ocamlVersion;
      });
  }
