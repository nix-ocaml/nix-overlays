{ callPackage, cmdliner }:


let mkocamlformat-rpc = version: callPackage ./generic.nix {
  inherit version cmdliner;
}; in

rec {
  ocamlformat-rpc_0_20_0 = mkocamlformat-rpc "0.20.0";

  ocamlformat-rpc_0_20_1 = mkocamlformat-rpc "0.20.1";

  ocamlformat-rpc = ocamlformat-rpc_0_20_1;
}
