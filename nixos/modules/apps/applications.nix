# { config, ... }:
# let
#   inherit (config.flake.modules) nixos;
#   zen-fixed = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (oldAttrs: {
#     src = oldAttrs.src.overrideAttrs (_: {
#       outputHash = "sha256-uyBF0+IWVNQP6EElAJLurf0sH8gx7vtQkiJ3PIvcoUk=";
#     });
#   });
# in
# {
#   flake.modules.nixos.applications = { pkgs, inputs, lib, ... }: {
#     imports = [
#       nixos.styupideasyapps
#       nixos.kitty
#     ];

#     fonts.packages = with pkgs; [
#        corefonts  # Arial, Times New Roman, Comic Sans, etc.
#        vista-fonts # Calibri, Consolas, Constantia, etc.
#        pkgs.nerd-fonts.jetbrains-mono
#        noto-fonts             # Noto Sans/Serif Thai
#        google-fonts           # Stylized Thai web fonts (Prompt, Itim, etc.)
#     ];
    
#     nixpkgs.config.allowUnfree = true;
#     environment.systemPackages = with pkgs; [
#       git
#       vim
#       wget                 # System resource monitor
#       nvtopPackages.full   # GPU process monitor
#       libreoffice
#       discord
#       docker-compose
#       obsidian
#       steam
#       typst         # Fast, modern academic paper renderer
#       texliveFull   # Complete LaTeX engine
#       pandoc        # Document conversion tool
#       pkgs.papers   # For reading PDF from gnome (SOOO Good)
#       pkgs.zed-editor-fhs
#       prismlauncher
#       pkgs.hyfetch
#       pkgs.vscodium
#       pkgs.neovim
#       pkgs.lutris
#       pkgs.obs-studio
#       adwaita-icon-theme
#       vanilla-dmz
#       pkgs.uv
#       pkgs.freecad
#       pkgs.rovium
#       pkgs.anki
#       easyeffects
#       pkgs.chromium
#       # For XFCE
#       # xfce.catfish
#       # xfce.gigolo
#       # xfce.orage
#       # xfce.xfburn
#       # xfce.xfce4-appfinder
#       # xfce.xfce4-clipman-plugin
#       # xfce.xfce4-cpugraph-plugin
#       # xfce.xfce4-dict
#       # xfce.xfce4-fsguard-plugin
#       # xfce.xfce4-genmon-plugin
#       # xfce.xfce4-netload-plugin
#       # xfce.xfce4-panel
#       # xfce.xfce4-pulseaudio-plugin
#       # xfce.xfce4-systemload-plugin
#       # xfce.xfce4-weather-plugin
#       # xfce.xfce4-whiskermenu-plugin
#       # xfce.xfce4-xkb-plugin
#       # xfce.xfdashboard
#       font-manager
#       pkgs.bun # All in one fast & easy-to-use tool
#       pkgs.home-manager # Home manager
#       pkgs.usbimager
#       # For ROS2
#       rosPackages.humble.desktop
#       rosPackages.humble.ros-base
#       colcon

#       zen-fixed
#     ];
#   };
# }


{ config, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.modules.nixos.applications = { pkgs, lib, ... }: {
    imports = [
      nixos.styupideasyapps
      nixos.kitty
    ];

    fonts.packages = with pkgs; [
       corefonts   # Arial, Times New Roman, Comic Sans, etc.
       vista-fonts  # Calibri, Consolas, Constantia, etc.
       pkgs.nerd-fonts.jetbrains-mono
       noto-fonts   # Noto Sans/Serif Thai
       google-fonts # Stylized Thai web fonts (Prompt, Itim, etc.)
    ];

    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      git
      vim
      wget                 # System resource monitor
      nvtopPackages.full   # GPU process monitor
      libreoffice
      discord
      docker-compose
      obsidian
      steam
      typst         # Fast, modern academic paper renderer
      texliveFull   # Complete LaTeX engine
      pandoc        # Document conversion tool
      pkgs.papers   # For reading PDF from gnome (SOOO Good)
      pkgs.zed-editor-fhs
      prismlauncher
      pkgs.hyfetch
      pkgs.vscodium
      pkgs.neovim
      pkgs.lutris
      pkgs.obs-studio
      adwaita-icon-theme
      vanilla-dmz
      pkgs.uv
      pkgs.freecad
      pkgs.rovium
      pkgs.anki
      easyeffects
      pkgs.chromium
      font-manager
      pkgs.bun # All in one fast & easy-to-use tool
      pkgs.home-manager # Home manager
      pkgs.usbimager

      # For ROS2
      rosPackages.humble.desktop
      rosPackages.humble.ros-base
      colcon

      # Redirects GUI elevation checks from 'sudo' directly to 'doas'
      (writeShellScriptBin "sudo" ''
        exec doas "$@"
      '')
    ];
  };
}
