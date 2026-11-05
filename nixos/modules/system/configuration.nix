# { self, ... }:
# {
#   flake.modules.nixos.system = { config, pkgs, libs, inputs, lib, ... }: {
#     imports = [
#       self.nixosModules.customKernel
#       self.nixosModules.plymouth-splash-kde
#     ];

#     # Merged nix.settings block (Dynamic resource allocation + Cuda cache)
#     nix.settings = {
#       experimental-features = [ "nix-command" "flakes" ];
#       max-jobs = "auto";
#       cores = 12; # Dynamically utilizes all P-cores and E-cores
#       substituters = [ "https://cache.nixos-cuda.org/" ];
#       trusted-public-keys = [ "cache.nixos-cuda.org-1:2hhlatXA9C9gld3u0N+J85z0dZ/9/Q16Z03l5w9d2d0=" ];
#     };

#     # Nix Store Cleanup & Optimization
#     nix.gc = {
#       automatic = true;
#       dates = "daily";
#       options = "--delete-older-than 7d";
#     };

#     nix.optimise = {
#       automatic = true;
#       dates = [ "weekly" ];
#     };

#     # Explicitly allow unfree packages for NVIDIA drivers
#     nixpkgs.config.allowUnfree = true;

#     # Bootloader Setup
#     boot.loader = {
#       systemd-boot.enable = false;
#       efi.canTouchEfiVariables = false; # Must be false when efiInstallAsRemovable = true
#       grub = {
#         enable = true;
#         device = "nodev";
#         efiSupport = true;
#         efiInstallAsRemovable = true; # Copies GRUB to /EFI/BOOT/BOOTX64.EFI
#       };
#     };

#     # Kernel Setup (Removed boot.kernelPackages to avoid conflict with kernel.nix)
#     boot.initrd.kernelModules = [ "xe" ];
#     boot.kernelParams = [ "nvidia-drm.modeset=1" ];

#     # Microcode & System Firmware Updates
#     hardware.cpu.intel.updateMicrocode = true;
#     hardware.enableAllFirmware = true;

#     # Graphics Acceleration
#     hardware.graphics = {
#       enable = true;
#       enable32Bit = true;
#       extraPackages = with pkgs; [
#         intel-media-driver
#         vpl-gpu-rt
#         intel-compute-runtime
#       ];
#     };

#     # NVIDIA RTX 5080 Desktop Configuration
#     # hardware.nvidia = {
#     #   modesetting.enable = true;
#     #   powerManagement.enable = true;
#     #   powerManagement.finegrained = false;
#     #   open = true; # Mandatory open-source kernel modules for RTX 50-series (Blackwell)
#     #   nvidiaSettings = true;
#     #   package = config.boot.kernelPackages.nvidiaPackages.beta;
#     # };

#     # Desktop Environment (XFCE4 + LightDM on X11)
#     # services.xserver = {
#     #   enable = true;
#     #   videoDrivers = [ "nvidia" ]; # Direct Xorg to render on the NVIDIA GPU
      
#     #   displayManager.gdm.enable = false;
#     #   desktopManager.gnome.enable = false;
      
#     #   displayManager.lightdm.enable = true;
#     #   desktopManager.xfce.enable = true;
#     # };

#     # services.displayManager.defaultSession = "xfce";
#     # services.xserver = {
#     #   enable = true;
#     #   videoDrivers = [ "nvidia" ]; # Direct Xorg to render on the NVIDIA GPU
      
#     #   displayManager.gdm.enable = false;
#     #   desktopManager.gnome.enable = false;
      
      
#     #   displayManager.lightdm.enable = false;
#     #   desktopManager.xfce.enable = false;
#     # };
#     # services.desktopManager.plasma6.enable = true;
#     # services.displayManager.sddm.enable = true;
#     # services.displayManager.sddm.wayland.enable = true;
#     # services = {
#     #   desktopManager.plasma6.enable = true;
#     #   xserver.enable = true;
#     #   displayManager = {
#     #     sddm = {
#     #       enable = true;
#     #       autoNumlock = true;
#     #       # wayland.enable = false;
#     #       settings = {
#     #         Users = {
#     #           RememberLastSession = false;
#     #         };
#     #       };
#     #     };
#     #   };
#     # };


#     services.displayManager.defaultSession = lib.mkForce "niri";

#     # Global X11 Environment Variables
#     # environment.sessionVariables = {
#     #   NIXOS_OZONE_WL = "0";
#     #   GDK_BACKEND = "x11";
#     #   QT_QPA_PLATFORM = "xcb";
#     #   SDL_VIDEODRIVER = "x11";
#     # };

#     # Networking & System Identification
#     networking.hostName = "nixos-btw";
#     networking.networkmanager.enable = true;

#     # Time & Regional Settings
#     time.timeZone = "Asia/Bangkok";
#     i18n.defaultLocale = "en_US.UTF-8";
#     # i18n.defaultLocale = "ja_JP.UTF-8";
#     i18n.extraLocaleSettings = {
#       LC_ADDRESS = "en_US.UTF-8";
#       LC_IDENTIFICATION = "en_US.UTF-8";
#       LC_MEASUREMENT = "en_US.UTF-8";
#       LC_MONETARY = "en_US.UTF-8";
#       LC_NAME = "en_US.UTF-8";
#       LC_NUMERIC = "en_US.UTF-8";
#       LC_PAPER = "en_US.UTF-8";
#       LC_TELEPHONE = "en_US.UTF-8";
#       LC_TIME = "en_US.UTF-8";
#     };

#     # Dynamic Binary Compatibility (Nix-LD)
#     programs.nix-ld.enable = true;
#     programs.nix-ld.libraries = with pkgs; [];

#     # Audio Stack
#     security.rtkit.enable = true;
#     services.pipewire = {
#       enable = true;
#       alsa.enable = true;
#       alsa.support32Bit = true;
#       pulse.enable = true; # Crucial for EasyEffects metadata tracking
#       wireplumber.enable = true;
#     };

#     # Bluetooth Configuration
#     hardware.bluetooth = {
#       enable = true;
#       powerOnBoot = true;
#       settings = {
#         General = {
#           FastConnectable = true;
#           Experimental = true; # Enables better codec support and battery reporting
#         };
#         Policy = {
#           AutoEnable = true;
#         };
#       };
#     };
#     services.blueman.enable = true;
    
#     # Auxiliary System Services
#     services.printing.enable = true;
#     services.openssh.enable = true;

#     # User Account Definition
#    users.users = {
#     lucas = {
#       isNormalUser = true;
#       description = "Lucas";
#       extraGroups = [ "audio" "networkmanager" "wheel" "docker" "vboxusers" "render" "video" ];
#       packages = with pkgs; [
#         mousepad
#         thunderbird
#       ];
#     };

#     lucas-Thinkpad = {
#       isNormalUser = true;
#       description = "lucas-Thinkpad";
#       extraGroups = [ "audio" "networkmanager" "wheel" "render" "video" ];
#       packages = with pkgs; [
#         firefox
#         vscodium
#       ];
#     };

#     guest = {
#       isNormalUser = true;
#       description = "Guest Account";
#       extraGroups = [ ];
#     };
#   };

#     # Privilege Elevation
#     security.sudo = {
#       enable = true;
#       wheelNeedsPassword = true;
#     };

#     # Sleep Workaround
#     systemd.services."systemd-suspend" = {
#       serviceConfig = {
#         Environment = "SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false";
#       };
#     };

#     # System Release Version
#     system.stateVersion = "24.11";
#   };
# }

{ self, ... }:
{
  flake.modules.nixos.system = { config, pkgs, lib, inputs, ... }: {
    imports = [
      self.nixosModules.customKernel
      self.nixosModules.plymouth-splash-kde
    ];

# ─── NIX OPTIMIZATION ───────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = "auto";
    cores = 12;
    auto-optimise-store = true; # Automatically deduplicates store files to save space
    
    substituters = [
      "https://cache.nixos.org/"
      "https://cache.nixos-cuda.org/" # Your existing CUDA cache
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrA/PkbE84pW03oToM4a432Q="
      "cache.nixos-cuda.org-1:2hhlatXA9C9gld3u0N+J85z0dZ/9/Q16Z03l5w9d2d0="
    ];
  };
  
  boot.loader.systemd-boot.configurationLimit = 3;
  
  # ─── I/O & STORAGE TUNING ───────────────────────────────────────
  boot.kernel.sysctl = {
    # Increase time before syncing data to disk (prevents system stuttering during heavy builds/updates)
    "vm.dirty_expire_centisecs" = 6000;
    "vm.dirty_writeback_centisecs" = 6000;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;
  };

    # Nix Store Cleanup & Optimization
    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 2d";
    };

    nix.optimise = {
      automatic = true;
      dates = [ "daily" ];
    };

    nixpkgs.config.allowUnfree = true;

    # Bootloader Setup
    boot.loader = {
      systemd-boot.enable = lib.mkForce true;
      efi.canTouchEfiVariables = lib.mkForce true;
      grub = {
        enable = lib.mkForce false;
        # device = "nodev";
        # efiSupport = true;
        # efiInstallAsRemovable = true;
      };
    };

    boot.initrd.kernelModules = [ "xe" ];
  # ─── CPU PERFORMANCE (Arrow Lake U9 285K) ──────────────────────
  boot.kernelParams = [
    "intel_iommu=on" "iommu=pt" # Enables IOMMU (Required for future GPU passthrough/VMs)
  ];
  boot.tmp.useTmpfs = false;
  boot.tmp.cleanOnBoot = true;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance"; # Keeps CPU clocks high for gaming/LLMs
  };

    hardware.cpu.intel.updateMicrocode = true;
    hardware.enableAllFirmware = true;

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vpl-gpu-rt
        intel-compute-runtime
      ];
    };

    services.displayManager.defaultSession = lib.mkForce "niri";

#<<<<<<< Updated upstream
    # Global X11 Environment Variables
    # environment.sessionVariables = {
    #   NIXOS_OZONE_WL = "0";
    #   GDK_BACKEND = "x11";
    #   QT_QPA_PLATFORM = "xcb";
    #   SDL_VIDEODRIVER = "x11";
    # };

    # Networking & System Identification
#    networking.hostName = "nixos";
#=======
    networking.hostName = "nixos-btw";
#>>>>>>> Stashed changes
    networking.networkmanager.enable = true;

    time.timeZone = "Asia/Bangkok";
    i18n.defaultLocale = "en_US.UTF-8";
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

    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [];

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = { FastConnectable = true; Experimental = true; };
        Policy = { AutoEnable = true; };
      };
    };
    services.blueman.enable = true;
    
    services.printing.enable = true;
    services.openssh.enable = true;

    users.users = {
      lucas = {
        isNormalUser = true;
        description = "Lucas";
        extraGroups = [ "audio" "networkmanager" "wheel" "docker" "vboxusers" "render" "video" "lpadmin" ];
        packages = with pkgs; [ mousepad thunderbird ];
      };
      lucas-Thinkpad = {
        isNormalUser = true;
        description = "lucas-Thinkpad";
        extraGroups = [ "audio" "networkmanager" "wheel" "render" "video" ];
        packages = with pkgs; [ firefox vscodium ];
      };
      guest = {
        isNormalUser = true;
        description = "Guest Account";
        extraGroups = [ ];
      };
    };

    # security.sudo = {
    #   enable = true;
    #   wheelNeedsPassword = true;
    # };
    security.sudo.enable = false;
    security.doas = {
      enable = true;

      extraRules = [{
        groups = [ "wheel" ];
        persist = true;
      }];
    };

    systemd.services."systemd-suspend" = {
      serviceConfig = {
        Environment = "SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false";
      };
    };

    system.stateVersion = "24.11";
  };
}
