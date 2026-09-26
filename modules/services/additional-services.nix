{ ... }:
{
  flake.modules.nixos.additional-services = { pkgs, ... }: {
    # VirtualBox
    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };

    programs.firefox.enable = true;
    programs.steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    programs.java.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # Virtualisation (Docker)
    virtualisation.docker.enable = true;

    # SearXNG Service
    services.searx = {
      enable = true;
      package = pkgs.searxng;
      redisCreateLocally = true;
      environmentFile = "/var/lib/searx/searxng.env";
      settings = {
        server = {
          port = 8080;
          bind_address = "127.0.0.1";
        };
        general = {
          debug = false;
          instance_name = "My SearXNG Engine";
        };
        search = {
          safe_search = 0;
          autocomplete = "google";
        };
      };
    };

    # Ollama Service (CUDA enabled for RTX 5080)
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
      host = "0.0.0.0";
      port = 11434;
      environmentVariables = {
        OLLAMA_ORIGINS = "*";
      };
    };

    # ACME Security
    security.acme = {
      acceptTerms = true;
      defaults.email = "lucas.chaleenon.poptie@gmail.com";
    };

    # DirenV for vim integration in vscodium
    programs.direnv.enable = true;

    # Firewall
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 11434 ];
      trustedInterfaces = [ "docker0" ];
    };
    services.flatpak.enable = true; # For Flatpak services
    # Bash -> Fish
    programs.fish.enable = true;

  };
}