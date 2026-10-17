# # { inputs, ... }:
# # {
# #   flake.modules.nixos.ros = {
# #     nixpkgs.overlays = [
# #       inputs.nix-ros-overlay.overlays.default
# #       (final: prev: {
# #         libfyaml = prev.libfyaml.overrideAttrs (oldAttrs: {
# #           patches = prev.lib.unique (oldAttrs.patches or [ ]);
# #         });
# #       })
# #       (final: prev: {
# #         mailspring = prev.symlinkJoin {
# #           name = "mailspring";
# #           paths = [ prev.mailspring ];
# #           nativeBuildInputs = [ prev.makeWrapper ];
# #           postBuild = ''
# #             wrapProgram $out/bin/mailspring \
# #               --add-flags "--password-store=kwallet5"
# #           '';
# #         };
# #       })
# #     ];
# #   };
# # }

# { inputs, ... }:
# {
#   flake.modules.nixos.ros = {
#     # Permit insecure/EOL Electron dependency required by Mailspring
#     nixpkgs.config.permittedInsecurePackages = [
#       "electron-40.10.5"
#     ];

#     # Pull pre-compiled ROS binaries when available
#     nix.settings = {
#       substituters = [ "https://ros.cachix.org" ];
#       trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
#     };

#     nixpkgs.overlays = [
#       inputs.nix-ros-overlay.overlays.default

#       # Fix GCC compilation errors in ROS Humble's rmw C code
#       (final: prev: {
#         rosPackages = prev.rosPackages // {
#           humble = prev.rosPackages.humble.overrideScope (rosFinal: rosPrev: {
#             rmw = rosPrev.rmw.overrideAttrs (oldAttrs: {
#               NIX_CFLAGS_COMPILE = (oldAttrs.NIX_CFLAGS_COMPILE or "")
#                 + " -Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types -Wno-error=format-security -Wno-error=int-conversion";
#             });
#           });
#         };
#       })

#       (final: prev: {
#         libfyaml = prev.libfyaml.overrideAttrs (oldAttrs: {
#           patches = prev.lib.unique (oldAttrs.patches or [ ]);
#         });
#       })

#       (final: prev: {
#         mailspring = prev.symlinkJoin {
#           name = "mailspring";
#           paths = [ prev.mailspring ];
#           nativeBuildInputs = [ prev.makeWrapper ];
#           postBuild = ''
#             wrapProgram $out/bin/mailspring \
#               --add-flags "--password-store=kwallet5"
#           '';
#         };
#       })
#     ];
#   };
# }

{ inputs, ... }:
{
  flake.modules.nixos.ros = {
    nix.settings = {
      trusted-users = [ "root" "@wheel" "lucas" ];
      substituters = [
        "https://cache.nixos.org"
        "https://ros.cachix.org"
        "https://cache.nixos-cuda.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      ];
    };

    nixpkgs.config.permittedInsecurePackages = [
      "electron-40.10.5"
    ];

    nixpkgs.overlays = [
      inputs.nix-ros-overlay.overlays.default

      (final: prev: {
        rosPackages = prev.rosPackages // {
          humble = prev.rosPackages.humble.overrideScope (rosFinal: rosPrev: {
            defaultRosPackageOverrides = old: {
              NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "")
                + " -Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types -Wno-error=format-security -Wno-error=int-conversion";
              NIX_CXXFLAGS_COMPILE = (old.NIX_CXXFLAGS_COMPILE or "")
                + " -Wno-error=deprecated-declarations -Wno-error=template-id-cdtor";
            };
          });
        };
      })

      (final: prev: {
        libfyaml = prev.libfyaml.overrideAttrs (oldAttrs: {
          patches = prev.lib.unique (oldAttrs.patches or [ ]);
        });
      })

      (final: prev: {
        mailspring = prev.symlinkJoin {
          name = "mailspring";
          paths = [ prev.mailspring ];
          nativeBuildInputs = [ prev.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/mailspring \
              --add-flags "--password-store=kwallet5"
          '';
        };
      })
    ];
  };
}
