# This might be helfpul later:
# https://www.reddit.com/r/NixOS/comments/6hswg4/how_do_i_turn_an_overlay_into_a_proper_package_set/
self: super:

let
  inherit (super) lib stdenv pkgs;
  ocamlPackages_4_09 =
    super.ocaml-ng.ocamlPackages_4_09.overrideScope' (pkgs.callPackage ./ocaml {});

in
  {
    opaline = super.opaline.override {
      ocamlPackages = ocamlPackages_4_09;
    };

    ocamlPackages = ocamlPackages_4_09;

    ocaml-ng = super.ocaml-ng // { inherit ocamlPackages_4_09; };
  }
