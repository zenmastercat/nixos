# { ... }:
# {
#   flake.nixosModules.customKernel = { config, pkgs, lib, ... }: 
#   let
#     customKernel = pkgs.linux_latest.override {
#       structuredExtraConfig = with lib.kernel; {
#         # Use mkForce on all custom flags to prevent any base-config conflicts
#         PREEMPT = lib.mkForce yes;
#         PREEMPT_VOLUNTARY = lib.mkForce no;
#         HZ_1000 = lib.mkForce yes;
        
#         MCORE2 = lib.mkForce yes;
#         GENERIC_CPU = lib.mkForce no;
        
#         X86_INTEL_PSTATE = lib.mkForce yes;
#         INTEL_IDLE = lib.mkForce yes;
#       };
#       ignoreConfigErrors = true; 
#     };
#   in {
#     boot.kernelPackages = pkgs.linuxPackagesFor customKernel;
    
#     hardware.cpu.intel.updateMicrocode = true;
    
#     hardware.graphics = { enable = true; enable32Bit = true; };
#     services.xserver.videoDrivers = [ "nvidia" ];
    
#     hardware.nvidia = {
#       modesetting.enable = true;
#       open = true;
#       powerManagement.enable = false;
#       package = config.boot.kernelPackages.nvidiaPackages.latest;
#       nvidiaSettings = true;
#     };
#   };
# }

# { ... }:
# {
#   flake.nixosModules.customKernel = { config, pkgs, lib, ... }: {
    
#     # 1. Use the pre-tuned XanMod kernel (Latest branch for 7.x support)
#     # This automatically includes full preemption, high tick rates, 
#     # and modern x86_64 CPU optimizations perfect for the 285K.
#     boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
    
#     # Required for the Intel 285K (Arrow Lake)
#     hardware.cpu.intel.updateMicrocode = true;
    
#     # Required for the RTX 5080 (Blackwell)
#     hardware.graphics = { 
#       enable = true; 
#       enable32Bit = true; 
#     };
#     services.xserver.videoDrivers = [ "nvidia" ];
    
#     hardware.nvidia = {
#       modesetting.enable = true;
#       open = true; # Mandatory for 50-series
#       powerManagement.enable = false;
#       # Force the latest beta or production driver for 50-series support
#       package = config.boot.kernelPackages.nvidiaPackages.latest;
#       nvidiaSettings = true;
#     };
#   };
# }

{ ... }:
{
  flake.nixosModules.customKernel = { config, pkgs, lib, ... }: {
    
        # ─── KERNEL SELECTION ──────────────────────────────────────────
    # Uses lib.mkDefault so specialisations can override it cleanly without errors
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_xanmod_latest;

    # ─── NVIDIA & GRAPHICS OPTIMIZATION ──────────────────────────
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vulkan-tools # For checking Vulkan driver health
      ];
    };

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      #---for using less electricity---
       prime = {
         offload = {
           enable = true;
           enableOffloadCmd = true;
         };
      #---better performance but more electricity---
      #  sync.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:2:0:0";
      };
      open = true;
      powerManagement.enable = false; # Disabled to prevent clock downshifting during gaming/LLMs
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };

    # ─── PERFORMANCE & STABILITY TWEAKS ──────────────────────────
    boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

    boot.kernelParams = [
      "intel_pstate=active"
      "nvidia-drm.modeset=1"
    ];

    hardware.cpu.intel.updateMicrocode = true;

    # ─── SPECIALISATIONS ──────────────────────────────────────────
    specialisation = {
      zen = {
        configuration = {
          system.nixos.tags = [ "zen-kernel" ];
          boot.kernelPackages = pkgs.linuxPackages_zen;
        };
      };
      stable = {
        configuration = {
          system.nixos.tags = [ "stable-kernel" ];
          boot.kernelPackages = pkgs.linuxPackages;
        };
      };
    };
  };
}
