{
  description = "ocaml-packages-overlay";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs?rev=37d145eafc8023e0b46c94a50fa3f5a9f2ec4b48";

  nixConfig = {
    extra-substituters = ["https://anmonteiro.nix-cache.workers.dev"];
    extra-trusted-public-keys = ["ocaml.nix-cache.com-1:/xI2h2+56rwFfKyyFVbkJSeGqSIYMC/Je+7XXqGKDIY="];
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

    patchChannel = {
      system,
      channel,
    }: let
      patches = [];
    in
      if patches == []
      then channel
      else
        (import channel {inherit system;}).pkgs.applyPatches {
          name = "nixpkgs-patched";
          src = channel;
          patches = patches;
        };
  in {
    lib = nixpkgs.lib;

    hydraJobs = builtins.listToAttrs (map
      (system: {
        name = system;
        value = import ./ci/hydra.nix {
          inherit system;
          pkgs = self.packages.${system};
        };
      })
      ["x86_64-linux" "aarch64-darwin"]);

    makePkgs = {
      system,
      extraOverlays ? [],
      ...
    } @ attrs: let
      pkgs = import nixpkgs ({
          inherit system;
          overlays = [self.overlays.default.${system}];
          config.allowUnfree = true;
        }
        // attrs);
    in
      /*
      You might read https://nixos.org/manual/nixpkgs/stable/#sec-overlays-argument and want to change this
      but because of how we're doing overlays we will be overriding any extraOverlays if we don't use `appendOverlays`
      */
      pkgs.appendOverlays extraOverlays;

    packages = forAllSystems (system: self.makePkgs {inherit system;});
    legacyPackages = forAllSystems (system: self.packages.${system});

    overlays.default = forAllSystems (system: (
      final: prev: let
        channel = patchChannel {
          inherit system;
          channel = nixpkgs;
        };
      in
        import channel {
          inherit system;
          overlays = [(import ./overlay channel)];
          config.allowUnfree = true;
        }
    ));
  };
}
