{ lib, config, inputs, ... }:
{
  options.configurations = {
    nixos = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.submodule {
        options.module = lib.mkOption { type = lib.types.deferredModule; };
      });
      default = { };
    };
    homeManager = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.submodule {
        options.module = lib.mkOption { type = lib.types.deferredModule; };
      });
      default = { };
    };
  };

  config = {
    flake.nixosConfigurations = lib.mapAttrs (
      name: { module }:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ module ];
      }
    ) config.configurations.nixos;

    flake.homeConfigurations = lib.mapAttrs (
      name: { module }:
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [ module ];
      }
    ) config.configurations.homeManager;
  };
}