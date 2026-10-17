{ inputs, ... }:
{
  flake.modules.nixos.auto-updates = { ... }: {
    system.autoUpgrade = {
      enable = true;
      flake = inputs.self.outPath;
      flags = [
        "--update-input"
        "nixpkgs"
        "-L"
      ];
      dates = "04:00";
      randomizedDelaySec = "45min";
    };
  };
}