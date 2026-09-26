{ ... }:
{
  flake.modules.nixos.kitty = { pkgs, ... }: {
    
    programs.kitty = {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 12;
      };
      settings = {
        background_opacity = "0.5";
        confirm_os_window_close = 0;
      };
    };

  };
}