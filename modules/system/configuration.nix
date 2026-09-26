{ self, ... }:
{
  flake.modules.nixos.system = { config, pkgs, libs, ... }: {
    imports = [
      self.nixosModules.customKernel
      self.nixosModules.plymouth-splash-kde
    ];

    # Merged nix.settings block (Dynamic resource allocation + Cuda cache)
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      max-jobs = "auto";
      cores = 12; # Dynamically utilizes all P-cores and E-cores
      substituters = [ "https://cache.nixos-cuda.org/" ];
      trusted-public-keys = [ "cache.nixos-cuda.org-1:2hhlatXA9C9gld3u0N+J85z0dZ/9/Q16Z03l5w9d2d0=" ];
    };

    # Nix Store Cleanup & Optimization
    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    nix.optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    # Explicitly allow unfree packages for NVIDIA drivers
    nixpkgs.config.allowUnfree = true;

    # Bootloader Setup
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Kernel Setup (Removed boot.kernelPackages to avoid conflict with kernel.nix)
    boot.initrd.kernelModules = [ "xe" ];
    boot.kernelParams = [ "nvidia-drm.modeset=1" ];

    # Microcode & System Firmware Updates
    hardware.cpu.intel.updateMicrocode = true;
    hardware.enableAllFirmware = true;

    # Graphics Acceleration
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vpl-gpu-rt
        intel-compute-runtime
      ];
    };

    # NVIDIA RTX 5080 Desktop Configuration
    # hardware.nvidia = {
    #   modesetting.enable = true;
    #   powerManagement.enable = true;
    #   powerManagement.finegrained = false;
    #   open = true; # Mandatory open-source kernel modules for RTX 50-series (Blackwell)
    #   nvidiaSettings = true;
    #   package = config.boot.kernelPackages.nvidiaPackages.beta;
    # };

    # Desktop Environment (XFCE4 + LightDM on X11)
    # services.xserver = {
    #   enable = true;
    #   videoDrivers = [ "nvidia" ]; # Direct Xorg to render on the NVIDIA GPU
      
    #   displayManager.gdm.enable = false;
    #   desktopManager.gnome.enable = false;
      
    #   displayManager.lightdm.enable = true;
    #   desktopManager.xfce.enable = true;
    # };

    # services.displayManager.defaultSession = "xfce";
    # services.xserver = {
    #   enable = true;
    #   videoDrivers = [ "nvidia" ]; # Direct Xorg to render on the NVIDIA GPU
      
    #   displayManager.gdm.enable = false;
    #   desktopManager.gnome.enable = false;
      
      
    #   displayManager.lightdm.enable = false;
    #   desktopManager.xfce.enable = false;
    # };
    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;


    # services.displayManager.defaultSession = "gnome";

    # Global X11 Environment Variables
    # environment.sessionVariables = {
    #   NIXOS_OZONE_WL = "0";
    #   GDK_BACKEND = "x11";
    #   QT_QPA_PLATFORM = "xcb";
    #   SDL_VIDEODRIVER = "x11";
    # };

    # Networking & System Identification
    networking.hostName = "nixos";
    networking.networkmanager.enable = true;

    # Time & Regional Settings
    time.timeZone = "Asia/Bangkok";
    i18n.defaultLocale = "en_US.UTF-8";
    # i18n.defaultLocale = "ja_JP.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    # Dynamic Binary Compatibility (Nix-LD)
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [];

    # Audio Stack
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;

    # Bluetooth Configuration
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          FastConnectable = true;
          Experimental = true; # Enables better codec support and battery reporting
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };
    services.blueman.enable = true;
    
    # Auxiliary System Services
    services.printing.enable = true;
    services.openssh.enable = true;

    # User Account Definition
    users.users.lucas = {
      isNormalUser = true;
      description = "Lucas";
      extraGroups = [ "audio" "networkmanager" "wheel" "docker" "vboxusers" ];
      packages = with pkgs; [
        mousepad
        thunderbird
      ];
    };

    # Privilege Elevation
    security.sudo = {
      enable = true;
      wheelNeedsPassword = true;
    };

    # Sleep Workaround
    systemd.services."systemd-suspend" = {
      serviceConfig = {
        Environment = "SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false";
      };
    };

    # System Release Version
    system.stateVersion = "24.11";
  };
}
