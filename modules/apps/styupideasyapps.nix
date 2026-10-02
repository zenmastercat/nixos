{ ... }:
{
  flake.modules.nixos.styupideasyapps = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      btop
      tmux
      pulseaudio # Provides 'pactl' for PipeWire or PulseAudio setups
      pkgs.hypnotix # For news sites international
      pkgs.pinta # Paint like program
    ];
  };
}