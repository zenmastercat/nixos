{ ... }:
{
  flake.modules.nixos.styupideasyapps = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      btop
    ];
  };
}