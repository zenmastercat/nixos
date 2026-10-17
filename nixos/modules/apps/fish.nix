{ ... }:
{
  flake.modules = {
    # NixOS aspect: Registers fish in /etc/shells and sets login shell
    nixos.fish = { pkgs, ... }: {
      programs.fish.enable = true;
      users.users.lucas.shell = pkgs.fish;
    };

    # Home Manager aspect: Fish configuration, aliases, prompt, etc.
    homeManager.fish = { ... }: {
      programs.fish = {
        enable = true;
        # Add interactiveInit, shellAliases, plugins here
      };
    };
  };
}