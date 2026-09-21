{ inputs, ... }:
{
  flake.modules.nixos.ros = {
    nixpkgs.overlays = [
      inputs.nix-ros-overlay.overlays.default
      (final: prev: {
        libfyaml = prev.libfyaml.overrideAttrs (oldAttrs: {
          patches = prev.lib.unique (oldAttrs.patches or [ ]);
        });
      })
    ];
  };
}