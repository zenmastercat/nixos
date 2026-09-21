{
  description = "NixOS Flake Configuration and Home-manager";

  inputs = {
    # Unstable Packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home-manager (Tracking master to match nixos-unstable)
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-ros-overlay
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";

    # Dendritic pattern requirements
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  outputs = inputs @ { flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.modules
        (import-tree ./modules)
      ];
    };
}