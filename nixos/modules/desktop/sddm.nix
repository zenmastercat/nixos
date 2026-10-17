# { ... }:
# {
#   flake.modules = {
#     # System Aspect
#     nixos.sddm = { pkgs, lib, ... }:
#       let
#         sddm-astronaut = (pkgs.sddm-astronaut.override {
#           embeddedTheme = "japanese_aesthetic";
#           themeConfig = {
#             HeaderTextColor = "#d5c4a1";
#             # Background = "Backgrounds/your-custom-background.png";
#           };
#         }).overrideAttrs (oldAttrs: {
#           # Optional: Uncomment if injecting a custom image from your repository
#           # installPhase = oldAttrs.installPhase + ''
#           #   chmod u+w $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/
#           #   cp ${./background.png} \
#           #     $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/your-custom-background.png
#           # '';
#         });
#       in
#       {
#         environment.systemPackages = [ sddm-astronaut ];

#         services.displayManager.sddm = {
#           enable = true;
#           package = pkgs.kdePackages.sddm;
#           extraPackages = with pkgs; [
#             kdePackages.qtmultimedia
#           ];
#           theme = "sddm-astronaut-theme";
#         };
#       };
#   };
# }
{ ... }:
{
  flake.modules = {
    # System Aspect
    nixos.sddm = { pkgs, lib, ... }:
      let
        sddm-astronaut = (pkgs.sddm-astronaut.override {
          embeddedTheme = "japanese_aesthetic";
          themeConfig = {
            HeaderTextColor = "#d5c4a1";
          };
        });
      in
      {
        environment.systemPackages = [ sddm-astronaut ];

        services.displayManager.sddm = {
          enable = true;
          wayland.enable = true; # Enables SDDM in pure Wayland mode
          package = pkgs.kdePackages.sddm;
          extraPackages = with pkgs; [
            kdePackages.qtmultimedia
          ];
          theme = "sddm-astronaut-theme";
        };
      };
  };
}