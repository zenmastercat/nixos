# { ... }:
# {
#   flake.modules.nixos.additional-services = { pkgs, ... }: {
#     # VirtualBox
#     virtualisation.virtualbox = {
#       # host config
#       host.enable = true;
#       host.enableExtensionPack = true;
#       # guest config for screen stuff/ etc
#       guest.enable = true;
#       guest.dragAndDrop = true;
#       # guest.x11 = true;
#     };
#     # virtualisation.virtualbox.host = {
#     #   enable = true;
#     #   enableExtensionPack = true;
#     # };
#     # virtualisation.virtualbox.guest.enable = true;
    

#     programs.firefox.enable = true;
#     programs.steam = {
#       enable = true;
#       extraCompatPackages = with pkgs; [
#         proton-ge-bin
#       ];
#       gamescopeSession.enable = true;
#       remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
#       dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
#     };
#     programs.java.enable = true;
#     programs.gnupg.agent = {
#       enable = true;
#       enableSSHSupport = true;
#     };

#     # Virtualisation (Docker)
#     virtualisation.docker.enable = true;

#     # SearXNG Service
#     services.searx = {
#       enable = true;
#       package = pkgs.searxng;
#       redisCreateLocally = true;
#       environmentFile = "/var/lib/searx/searxng.env";
#       settings = {
#         server = {
#           port = 8080;
#           bind_address = "127.0.0.1";
#         };
#         general = {
#           debug = false;
#           instance_name = "My SearXNG Engine";
#         };
#         search = {
#           safe_search = 0;
#           autocomplete = "google";
#         };
#       };
#     };

#     # Ollama Service (CUDA enabled for RTX 5080)
#     services.ollama = {
#       enable = true;
#       package = pkgs.ollama-cuda;
#       host = "0.0.0.0";
#       port = 11434;
#       environmentVariables = {
#         OLLAMA_KEEP_ALIVE = "-1"; # Fixed missing semicolon
#         OLLAMA_ORIGINS = "*";
#         # Bumps global context budget so reasoning models don't run out of tokens mid-thought
#         OLLAMA_CONTEXT_LENGTH = "16384";
#         # Prevent VRAM OOM on 16GB VRAM while driving desktop displays
#         OLLAMA_KV_CACHE_TYPE = "q4_0";
#         OLLAMA_NUM_PARALLEL = "1";
#         OLLAMA_MAX_LOADED_MODELS = "1";
#         OLLAMA_FLASH_ATTENTION = "1";
#       };
#     };

#     # Keep service running / auto-recover from CUDA driver resets
#     systemd.services.ollama = {
#       serviceConfig = {
#         Restart = "always";
#         RestartSec = "3s";
#         StartLimitIntervalSec = 0;
#       };
#     };

#     # Llama cpp Service (Cpu usage for better optimization of money)
#     # services.llama-cpp = {
#     #   enable = false;
#     #   package = pkgs.llama-cpp;

#     #   settings = {
#     #     host = "127.0.0.1";
#     #     port = 8080;
#     #     ctx-size = 16384; # Increased context budget to match long prompts
#     #     n-gpu-layers = 0; # CPU mode

#     #     # On Intel Arrow Lake (Core Ultra 9 285K), allocating only P-cores (8 threads) 
#     #     # yields significantly higher tok/s than 16 threads due to core switching overhead.
#     #     threads = 8;     

#     #     # Replace with a valid Hugging Face GGUF repository path
#     #     hf-repo = "unsloth/DeepSeek-R1-Distill-Qwen-14B-GGUF";
#     #     model = "DeepSeek-R1-Distill-Qwen-14B-Q4_K_M.gguf"; # Explicit filename inside HF repo
#     #   };
#     # };

#     services.llama-cpp = {
#       enable = false;
#     };

#   # Enable cache directory & SSL certificates for Hugging Face downloads
#   systemd.services.llama-cpp = {
#     serviceConfig = {
#       CacheDirectory = "llama-cpp";
#     };
#     environment = {
#       XDG_CACHE_HOME = "/var/cache/llama-cpp";
#       SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
#     };
#   };

#     # ACME Security
#     security.acme = {
#       acceptTerms = true;
#       defaults.email = "lucas.chaleenon.poptie@gmail.com";
#     };

#     # DirenV for vim integration in vscodium
#     programs.direnv.enable = true;

#     # Firewall
#     networking.firewall = {
#       enable = true;
#       allowedTCPPorts = [ 11434 ];
#       trustedInterfaces = [ "docker0" ];
#     };
#     services.flatpak.enable = true; # For Flatpak services

#   };
# }

{ ... }:
{
  flake.modules.nixos.additional-services = { pkgs, ... }: {
    
    # VirtualBox
    virtualisation.virtualbox = {
      host.enable = true;
      host.enableExtensionPack = true;
      guest.enable = true;
      guest.dragAndDrop = true;
    };

    # Steam, Firefox, Java, GnuPG, Direnv
    programs.firefox.enable = true;
    programs.java.enable = true;
    programs.direnv.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    programs.steam = {
      enable = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    # Virtualisation (Docker Engine + OCI Containers)
    virtualisation.docker.enable = true;

    # Declarative Open WebUI Container Setup (แก้ปัญหา 502 Timeout)
    # http://localhost:3001 for accessing llama-cpp via it's own web
    virtualisation.oci-containers.backend = "docker";
    virtualisation.oci-containers.containers.open-webui = {
      image = "ghcr.io/open-webui/open-webui:main";
      autoStart = true;
      ports = [ "3001:8080" ];
      environment = {
        ENABLE_OLLAMA_API = "False";    # Bypasses healthcheck hangs looking for Ollama
        RAG_EMBEDDING_ENGINE = "";     # Bypasses initial Hugging Face download stall
        AIOHTTP_CLIENT_TIMEOUT = "600";
        TASK_TIMEOUT = "600";
        ENABLE_RESPONSE_AUTO_SCROLL = "true";
      };
      extraOptions = [
        "--add-host=host.docker.internal:host-gateway"
      ];
      volumes = [
        "open-webui-data:/app/backend/data"
      ];
    };

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

    # Ollama Service (Optimized for RTX 5080 16GB)
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
      host = "0.0.0.0";
      port = 11434;
      environmentVariables = {
        OLLAMA_KEEP_ALIVE = "-1";
        OLLAMA_ORIGINS = "*";
        OLLAMA_CONTEXT_LENGTH = "16384";
        OLLAMA_KV_CACHE_TYPE = "q4_0";
        OLLAMA_NUM_PARALLEL = "1";
        OLLAMA_MAX_LOADED_MODELS = "1";
        OLLAMA_FLASH_ATTENTION = "1";
      };
    };

    # Auto-recovery systemd service
    systemd.services.ollama = {
      serviceConfig = {
        Restart = "always";
        RestartSec = "3s";
        StartLimitIntervalSec = 0;
      };
    };

    # Llama-cpp (Disabled until GGUF is downloaded)
    # services.llama-cpp = {
    #   enable = false;
    # };
    # Llama-cpp Service (CPU Offloading on Intel Core Ultra 9 285K)
    services.llama-cpp = {
      enable = true;
      package = pkgs.llama-cpp;

      settings = {
        model = "/var/lib/llama-cpp/DeepSeek-R1-Distill-Qwen-14B-Q4_K_M.gguf";
        host = "127.0.0.1";
        port = 8081; # Changed from 8080 to avoid SearXNG collision
        ctx-size = 16384;
        n-gpu-layers = 0;
        threads = 8;
      };
    };

    # ACME Security
    security.acme = {
      acceptTerms = true;
      defaults.email = "lucas.chaleenon.poptie@gmail.com";
    };

    # Firewall (อนุญาต Port และ Docker Interface)
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 11434 3000 ];
      trustedInterfaces = [ "docker0" ];
    };

    services.flatpak.enable = true;
  };
}