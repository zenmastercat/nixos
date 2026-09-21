{ config, inputs, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  # NixOS Configuration Target
  configurations.nixos.nixos.module = {
    _module.args = { inherit inputs; };
    imports = [
      nixos.system
      nixos.hardware
      nixos.auto-updates
      nixos.applications
      nixos.additional-services
      nixos.ros
    ];
  };

  # Home Manager Profile Target
  configurations.homeManager.myprofile.module = {
    imports = [
      homeManager.myprofile
    ];
  };
}