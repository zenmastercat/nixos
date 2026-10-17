{ config, ... }:
{
  flake.modules = {
    # Home Manager Aspect (Terminal config, font, opacity)
    homeManager.kitty = { pkgs, ... }: {
      programs.kitty = {
        enable = true;
        themeFile = "gruvbox-dark";
        font = {
          name = "JetBrainsMono Nerd Font";
          size = 12;
        };
        settings = {
          shell = "${pkgs.fish}/bin/fish";
          background_opacity = "0.75";
          confirm_os_window_close = 0;
        };
      };
    };

    # NixOS Aspect (System-level package install, if needed)
    nixos.kitty = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.kitty ];
    };

  };
}