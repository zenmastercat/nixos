USER_NAME := $(if $(SUDO_USER),$(SUDO_USER),$(USER))
.PHONY: rebuild-switch

rebuild-switch:
	git add .
	sudo nixos-rebuild switch --flake .#nixos

.PHONY: rebuild.home-manager

rebuild.home-manager:
	git add .
	sudo -u $(USER_NAME) -H home-manager switch --flake .#myprofile

.PHONY: clean

clean:
	# Delete older boot generations
               sudo nix-env --delete-generations old -p /nix/var/nix/profiles/system

               # Collect garbage to free disk space
               sudo nix-collect-garbage -d

               # Rebuild your bootloader configuration to remove old EFI entries
               sudo nixos-rebuild switch

.PHONY: git-commit

git-commit:
	sudo git add .
	sudo git commit -m "configgyuuu"
