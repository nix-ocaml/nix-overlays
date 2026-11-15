{ overlays }:
let
  pkgs = overlays.legacyPackages.x86_64-linux;
  select = scope: {
    inherit (scope) lwt;
  };
in
{
  native-5_5 = select pkgs.ocaml-ng.ocamlPackages_5_5;
  native-5_6 = select pkgs.ocaml-ng.ocamlPackages_5_6;
  musl-5_5 = select pkgs.pkgsCross.musl64.ocaml-ng.ocamlPackages_5_5;
  musl-5_6 = select pkgs.pkgsCross.musl64.ocaml-ng.ocamlPackages_5_6;
}
