{ self, ... }:
{
  flake.nixosModules.plymouth-splash-kde = { config, pkgs, libs, ... }: {
    boot = {
      plymouth = {
        enable = true;
        # Optional: choose a specific theme package if you have one installed or packaged
        theme = "AccretionDisk"; 
      };
  
  # Quiet the kernel logs so text doesn't bleed through the splash screen
      consoleLogLevel = 0;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=false"
      ];
      
      # Recommended for proper initialization with Plymouth
      initrd.systemd.enable = true;
    };

  };
}
