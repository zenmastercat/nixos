{ ... }:
{
  flake.modules.homeManager.myprofile = { pkgs, ... }: {
    home = {
      packages = with pkgs; [
        pkgs.gnumake
        pkgs.gcc
        cowsay
        lolcat
      ];

      username = "lucas";
      homeDirectory = "/home/lucas";

      stateVersion = "23.11";
    };
  };
}