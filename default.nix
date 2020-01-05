# This might be helfpul later:
# https://www.reddit.com/r/NixOS/comments/6hswg4/how_do_i_turn_an_overlay_into_a_proper_package_set/
self: super:

let
  inherit (super) lib stdenv pkgs;

in
  {
    ocamlPackages = super.ocaml-ng.ocamlPackages_4_09.overrideScope' (pkgs.callPackage ./ocaml {});
    ocaml-ng = super.ocaml-ng // {
      ocamlPackages_4_09 = super.ocaml-ng.ocamlPackages_4_09.overrideScope'
        (super.callPackage ./ocaml {});
    };
  }
