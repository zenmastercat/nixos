# { config, inputs, ... }:
# let
#   inherit (config.flake.modules) nixos homeManager;
# in
# {
#   # NixOS Configuration Target
#   configurations.nixos.nixos.module = {
#     _module.args = { inherit inputs; };
#     imports = [
#       nixos.system
#       nixos.hardware
#       nixos.auto-updates
#       nixos.applications
#       nixos.additional-services
#       nixos.ros
#       nixos.fish
#     ];
#   };

#   # 2. User-level Home Manager Configuration
#   home-manager.useGlobalPkgs = true;
#   home-manager.useUserPackages = true;

#   # Home Manager Profile Target
#   configurations.homeManager.myprofile.module = {
#     imports = [
#       homeManager.fish
#       homeManager.myprofile
#       homeManager.kitty
#     ];
#   };
# }

{ config, inputs, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  # NixOS Configuration Target
  configurations.nixos.nixos.module = {
    _module.args = { inherit inputs; };
    
    imports = [
      # 1. Import Home Manager's NixOS module so NixOS recognizes 'home-manager.*' options
      inputs.home-manager.nixosModules.home-manager

      # 2. NixOS System Aspects
      nixos.system
      nixos.hardware
      nixos.auto-updates
      nixos.applications
      nixos.additional-services
      nixos.ros
      nixos.fish
    ];

    # 3. Home Manager Configuration (Moved inside NixOS module)
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.lucas = {
        imports = [
          homeManager.fish
          homeManager.myprofile
          homeManager.kitty
        ];
      };
    };
  };

  # Standalone Home Manager target (if building HM separately outside NixOS rebuilds)
  configurations.homeManager.myprofile.module = {
    imports = [
      homeManager.fish
      homeManager.myprofile
      homeManager.kitty
    ];
  };
}