{ ... }:
{
  flake.modules.nixos.additional-services = { config, pkgs, modulesPath, lib,  ... }: {
    imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

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
    # virtualisation.oci-containers.backend = "docker";
    # virtualisation.oci-containers.containers.open-webui = {
    #   image = "ghcr.io/open-webui/open-webui:main";
    #   autoStart = true;
    #   ports = [ "3001:8080" ];
    #   environment = {
    #     ENABLE_OLLAMA_API = "False";
    #     RAG_EMBEDDING_ENGINE = "";
    #     # Set 1-hour timeouts (3600s) to prevent web UI response drops on 32B models
    #     AIOHTTP_CLIENT_TIMEOUT = "3600";
    #     AIOHTTP_CLIENT_TIMEOUT_TOTAL = "3600";
    #     TASK_TIMEOUT = "3600";
    #     ENABLE_RESPONSE_AUTO_SCROLL = "true";
    #     ENABLE_PERSISTENT_CONFIG = "False"; # Forces container to honor these environment timeouts
    #     DEFAULT_MODEL_PARAMS = "{\"max_tokens\": -1}";
    #   };
    #   extraOptions = [
    #     "--add-host=host.docker.internal:host-gateway"
    #     "--restart=always" # Forces Docker to automatically restart Open WebUI if it crashes
    #   ];
    #   volumes = [
    #     "open-webui-data:/app/backend/data"
    #   ];
    # };
    virtualisation.oci-containers.backend = "docker";
    virtualisation.oci-containers.containers.open-webui = {
      image = "ghcr.io/open-webui/open-webui:main";
      autoStart = true;
      ports = [ "3001:8080" ];
      environment = {
        ENABLE_OLLAMA_API = "True";
        OLLAMA_BASE_URL = "http://host.docker.internal:11434";
        RAG_EMBEDDING_ENGINE = "";
        AIOHTTP_CLIENT_TIMEOUT = "3600";
        TASK_TIMEOUT = "3600";
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
        # OLLAMA_KEEP_ALIVE = "-1";       # Keeps 32B models pinned in RAM/VRAM to prevent unload delays
        OLLAMA_KEEP_ALIVE = "3600"; 
        OLLAMA_ORIGINS = "*";
        OLLAMA_CONTEXT_LENGTH = "100000"; # 32k context balances RAM usage for 32B models
        OLLAMA_KV_CACHE_TYPE = "q4_0";  # Quantized KV cache saves ~3GB VRAM, allowing more layers on GPU
        OLLAMA_NUM_PARALLEL = "1";       # Prevents multi-request memory spikes
        OLLAMA_MAX_LOADED_MODELS = "1";
        OLLAMA_FLASH_ATTENTION = "1";
        OLLAMA_NUM_PREDICT = "-1";       # Disables token count stopping limits
        OLLAMA_MAX_QUEUE = "512";        # Queues requests instead of dropping connection
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
    services.llama-cpp = {
      enable = true;
      package = pkgs.llama-cpp.override { cudaSupport = true; };

      settings = {
        model = "/var/lib/llama-cpp/DeepSeek-R1-Distill-Qwen-14B-Q4_K_M.gguf";
        host = "127.0.0.1";
        port = 8081;
        ctx-size = 32768;
        n-gpu-layers = 42; # Fits optimal layers into 16GB VRAM; remaining run on Core Ultra 9
        threads = 24;      # Maximizes CPU fallback processing on Intel Core Ultra 9 285K
      };
    };
    systemd.services.llama-cpp.wantedBy = lib.mkForce [ ]; # Prevent systemd from launching llama-cpp on boot

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

    # Remotely use nixos on any kde desktop enviroment machine
    # services.xrdp = {
    #   enable = true;
    #   defaultWindowManager = "startplasma-x11";
    #   openFirewall = true;
    # };

    services.flatpak.enable = true;
  };
}