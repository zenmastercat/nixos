{ ... }:
{
  flake.modules.nixos.virtualbox-host = { pkgs, ... }: {
    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
      enableKvm = true;
      addNetworkInterface = false;
    };

    users.users.lucas.extraGroups = [ "vboxusers" ];
    users.extraGroups.vboxusers.members = [ "lucas" ];
  };
}
