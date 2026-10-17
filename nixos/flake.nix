# # {
# #   description = "NixOS Flake Configuration and Home-manager";

# #   inputs = {
# #     # Unstable Packages
# #     nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

# #     # Home-manager (Tracking master to match nixos-unstable)
# #     home-manager = {
# #       url = "github:nix-community/home-manager/master";
# #       inputs.nixpkgs.follows = "nixpkgs";
# #     };

# #     # nix-ros-overlay
# #     nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";

# #     # Dendritic pattern requirements
# #     flake-parts.url = "github:hercules-ci/flake-parts";
# #     import-tree.url = "github:vic/import-tree";
# #   };

# #   outputs = inputs @ { flake-parts, import-tree, ... }:
# #     flake-parts.lib.mkFlake { inherit inputs; } {
# #       imports = [
# #         inputs.flake-parts.flakeModules.modules
# #         (import-tree ./modules)
# #       ];
# #     };
# # }
# {
#   description = "NixOS Flake Configuration and Home-manager";

#   inputs = {
#     # Unstable Packages
#     nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

#     # Home-manager
#     home-manager = {
#       url = "github:nix-community/home-manager/master";
#       inputs.nixpkgs.follows = "nixpkgs";
#     };

#     # Noctalia Desktop Shell
#     noctalia = {
#       url = "github:noctalia-dev/noctalia";
#       inputs.nixpkgs.follows = "nixpkgs";
#     };

#     # Zen Browser
#     zen-browser = {
#       url = "github:youwen5/zen-browser-flake";
#       inputs.nixpkgs.follows = "nixpkgs";
#     };

#     nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";
#     flake-parts.url = "github:hercules-ci/flake-parts";
#     import-tree.url = "github:vic/import-tree";
#   };

#   outputs = inputs @ { flake-parts, import-tree, ... }:
#     flake-parts.lib.mkFlake { inherit inputs; } {
#       imports = [
#         inputs.flake-parts.flakeModules.modules
#         (import-tree ./modules)
#       ];
#     };
# }

{
  description = "NixOS Flake Configuration and Home-manager";

  # Enable the ROS Cachix binary cache so pre-compiled packages can be fetched directly
  nixConfig = {
    extra-substituters = [ "https://ros.cachix.org" ];
    extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
  };

  inputs = {
    # nix-ros-overlay
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";

    # Pin nixpkgs to follow nix-ros-overlay to prevent GCC 14 build failures
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";

    # Home-manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia Desktop Shell
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zen Browser
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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