# { ... }:
# {
#   flake.modules = {
#     # System Aspect
#     nixos.niri = { pkgs, lib, inputs, ... }: {
#       programs.niri.enable = true;

#       services.displayManager.defaultSession = lib.mkForce "niri";
#       services.displayManager.sessionPackages = [ pkgs.niri ];

#       environment.systemPackages = [
#         inputs.noctalia.packages.${pkgs.system}.default
#         pkgs.fuzzel
#         pkgs.xwayland-satellite
#         pkgs.wl-clipboard
#         pkgs.alacritty
#         pkgs.apple-cursor
#       ];
#     };

#     # Home Manager Aspect
#     homeManager.niri = { ... }: {
#       xdg.configFile."niri/config.kdl".text = ''
#         // Autostart Noctalia
#         spawn-at-startup "noctalia"

#         // Mouse Focus Configuration
#         cursor {
#             xcursor-theme "macOS" // Must match the installed theme name
#             xcursor-size 24               // Set your preferred size (e.g., 24 or 48)
#             // shake to enlarge like for macOS
#             shake-to-enlarge {
#                   //off
#                   grow
#                   grow-speed 0.01
#                         threshold 2000
#                   hold-duration-ms 1500
#                   zoom-factor 5
#             }
#         }
#         magnifier {
#             // off
#             zoom-factor 3
#             track-cursor false 
#             //scale-cursor false
#         }
#         input {
#             focus-follows-mouse

#             keyboard {
#                 xkb {
#                     layout "us,th"
#                     options "grp:alt_shift_toggle"
#                 }
#             }
#         }

#         // Layout Configuration (focus-ring must be nested here)
#         layout {
#             focus-ring {
#                 off
#             }
#         }

#         // Dim Inactive Windows
#         // window-rule {
#         //     match is-active=false
#         //     opacity 0.95
#         // }

#         // Dual Monitor Configuration
#         output "DP-2" {
#             mode "1920x1080@143.981"
#             scale 1.0
#             position x=0 y=0
#         }

#         output "HDMI-A-1" {
#             mode "3840x2160@144.001"
#             scale 1.75
#             position x=1920 y=0
#         }

#         // Keybindings
#         binds {
#             Mod+Return { spawn "alacritty"; }
#             Mod+Space  { spawn "fuzzel"; }
#             Mod+Q      { close-window; }

#             Mod+Left  { focus-column-left; }
#             Mod+Right { focus-column-right; }
#             Mod+Down  { focus-window-down; }
#             Mod+Up    { focus-window-up; }

#             Mod+Shift+Left  { move-column-left; }
#             Mod+Shift+Right { move-column-right; }
#             Mod+Shift+Down  { move-window-down; }
#             Mod+Shift+Up    { move-window-up; }

#             Mod+R { switch-preset-column-width; }
#             Mod+Shift+F { maximize-column; }
#             Mod+F { maximize-window-to-edges; }

#             Mod+1 { focus-workspace 1; }
#             Mod+2 { focus-workspace 2; }
#             Mod+3 { focus-workspace 3; }
#             Mod+4 { focus-workspace 4; }
#             Mod+Shift+1 { move-column-to-workspace 1; }
#             Mod+Shift+2 { move-column-to-workspace 2; }

#             // Mod+Equal { zoom-in; }
#             // Mod+Minus { zoom-out; }
#             Mod+Alt+WheelScrollUp   { adjust-magnifier-zoom 0.2; }
#             Mod+Alt+WheelScrollDown { adjust-magnifier-zoom -0.2; }
#             Mod+Shift+Z         { toggle-magnifier; }

#             Mod+Shift+E { quit; }
#         }
#       '';
#     };
#   };
# }

{ ... }:
{
  flake.modules = {
    # System Aspect
    nixos.niri = { pkgs, lib, inputs, ... }: 
      let
        # Override standard Niri to use SHORiN-KiWATA's fork
        shorin-niri = pkgs.niri.overrideAttrs (oldAttrs: rec {
          src = pkgs.fetchFromGitHub {
            owner = "SHORiN-KiWATA";
            repo = "niri";
            rev = "main";
            hash = "sha256-1PITf5iU3Yix+Rwtc44NnGUH8Nl6I00cFiYK2J/PZ4g=";
          };

          cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
            inherit src;
            hash = "sha256-qJboQH47ywa7a6CYC/NMH/vw7Z4fibKERIktzvOrSfI="; # Temporarily set to fakeHash
          };

          # Disable tests since EGL display is unavailable inside the Nix build sandbox
          doCheck = false;
        });
      in
      {
        programs.niri = {
          enable = true;
          package = shorin-niri;
        };

        services.displayManager.defaultSession = lib.mkForce "niri";
        services.displayManager.sessionPackages = [ shorin-niri ];

        environment.systemPackages = [
          inputs.noctalia.packages.${pkgs.system}.default
          pkgs.fuzzel
          pkgs.xwayland-satellite
          pkgs.wl-clipboard
          pkgs.alacritty
          pkgs.apple-cursor
        ];
      };

    # Home Manager Aspect
    homeManager.niri = { ... }: {
      xdg.configFile."niri/config.kdl".text = ''
        // Autostart Noctalia
        spawn-at-startup "noctalia"
        spawn-at-startup "mailspring"

        // Mouse Focus Configuration
        cursor {
            xcursor-theme "macOS"
            xcursor-size 24
            
            // Fork Feature: shake to enlarge
            shake-to-enlarge {
                grow
                grow-speed 0.1
                threshold 900
                hold-duration-ms 1500
                zoom-factor 5
            }
        }

        // Fork Feature: magnifier
        magnifier {
            zoom-factor 3
            track-cursor false
        }

        input {
            focus-follows-mouse

            keyboard {
                xkb {
                    layout "us,th"
                    options "grp:alt_shift_toggle"
                }
            }
        }

        layout {
            focus-ring {
                off
            }
        }

        // Dual Monitor Configuration
        output "DP-2" {
            mode "1920x1080@143.981"
            scale 1.0
            position x=0 y=0
        }

        output "HDMI-A-1" {
            mode "3840x2160@144.001"
            scale 1.75
            position x=1920 y=0
        }

        // Keybindings
        binds {
            Mod+Return { spawn "alacritty"; }
            Mod+Space  { spawn "fuzzel"; }
            Mod+Q      { close-window; }

            Mod+Left  { focus-column-left; }
            Mod+Right { focus-column-right; }
            Mod+Down  { focus-window-down; }
            Mod+Up    { focus-window-up; }

            Mod+Shift+Left  { move-column-left; }
            Mod+Shift+Right { move-column-right; }
            Mod+Shift+Down  { move-window-down; }
            Mod+Shift+Up    { move-window-up; }

            Mod+R { switch-preset-column-width; }
            Mod+Shift+F { maximize-column; }
            Mod+F { maximize-window-to-edges; }

            Mod+1 { focus-workspace 1; }
            Mod+2 { focus-workspace 2; }
            Mod+3 { focus-workspace 3; }
            Mod+4 { focus-workspace 4; }
            Mod+Shift+1 { move-column-to-workspace 1; }
            Mod+Shift+2 { move-column-to-workspace 2; }

            // Fork Keybindings
            Mod+Alt+WheelScrollUp   { adjust-magnifier-zoom 0.2; }
            Mod+Alt+WheelScrollDown { adjust-magnifier-zoom -0.2; }
            Mod+Shift+Z             { toggle-magnifier; }

            Mod+Shift+E { quit; }
        }
      '';
    };
  };
}