{ ... }:
{
  flake.modules.nixos.styupideasyapps = { pkgs, inputs, ... }: {
    environment.systemPackages = with pkgs; [
      btop
      tmux
      pulseaudio # Provides 'pactl' for PipeWire or PulseAudio setups
      pkgs.hypnotix # For news sites international
      pkgs.pinta # Paint like program
      pkgs.emacs # The Church of EMACS GNU is the distro with Linux the Kernel
      pciutils
      pkgs.ungoogled-chromium
      pkgs.kdePackages.dolphin
      pkgs.winboat
      freerdp
      
      pkgs.cups-brother-dcp1610wlpr
      # brother
      cups
      cups-browsed

      pkgs.openssh
      mailspring
      pkgs.kdePackages.kwallet
      pkgs.kdePackages.kwalletmanager
     
      # winetricks (all versions)
      winetricks
      wineWow64Packages.stable

      pkgs.vivaldi
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

      pkgs.rustdesk

      unzip
    ];
  };
}
