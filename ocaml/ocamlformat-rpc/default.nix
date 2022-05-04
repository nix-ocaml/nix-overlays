{ callPackage, ocaml, lib }:


let mkocamlformat-rpc = callPackage ./generic.nix; in

rec {
  ocamlformat-rpc_0_20_0 = mkocamlformat-rpc {
    version = "0.20.0";
    ocamlformat = null;
  };

  ocamlformat-rpc_0_20_1 = mkocamlformat-rpc {
    version = "0.20.1";
    ocamlformat = null;
  };

  ocamlformat-rpc_0_21_0 =
    if lib.versionAtLeast ocaml.version "4.13" then
      mkocamlformat-rpc { version = "0.21.0"; }
    else null;

  ocamlformat-rpc =
    if lib.versionAtLeast ocaml.version "4.13" then
      ocamlformat-rpc_0_21_0
    else ocamlformat-rpc_0_20_1;
}
