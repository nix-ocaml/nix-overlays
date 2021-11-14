{
  description = "ocaml-packages-overlay";

  outputs = { self }: {
    overlay = final: prev: (import ./default.nix) final prev;
  };
}
