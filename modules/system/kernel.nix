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
    # Using XanMod for lower latency and better scheduler performance.
    # NOTE: If you encounter any hardware instability with the 285K/5080, 
    # you can switch this to pkgs.linuxPackages_xanmod_edge for newer upstream patches.
    boot.kernelPackages = pkgs.linuxPackages_xanmod_latest; 

    # ─── NVIDIA & GRAPHICS OPTIMIZATION ──────────────────────────
    # Required for the RTX 5080 (Blackwell) and Dual Monitor stability.
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    services.xserver.videoDrivers = [ "nvidia" ]; 

    hardware.nvidia = {
      # Mandatory for 50-series and dual-monitor refresh rate handling.
      modesetting.enable = true; 
      open = true; 
      
      # Set to true if you want the GPU to enter low-power states; 
      # leave false for maximum raw performance/constant clock speeds.
      powerManagement.enable = false; 
      
      # Use the production driver for maximum stability
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };

    # ─── PERFORMANCE & STABILITY TWEAKS ──────────────────────────
    
    # 1. Early Loading: Prevents resolution flickering on dual monitors during boot
    boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

    # 2. CPU Performance: Force the U9 285K into performance mode
    # This prevents the kernel from aggressively downclocking the P-cores.
    boot.kernelParams = [ 
      "intel_pstate=active" 
      "nvidia-drm.modeset=1" 
    ];
    # Required for the Intel 285K (Arrow Lake)
    hardware.cpu.intel.updateMicrocode = true;
    # 3. Memory Optimization: Transparent Huge Pages (THP)
    # Helps with high-memory workloads on 32GB+ systems
    boot.kernel.sysctl = {
      "vm.nr_hugepages" = 0; # Let the system manage them dynamically
      "vm.swappiness" = 10;  # Reduce swapping to keep performance in RAM
    };
  };
}