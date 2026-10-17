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
	sudo nix-env --delete-generations old -p /nix/var/nix/profiles/system
	sudo nix-collect-garbage -d
	sudo nixos-rebuild switch

.PHONY: git-commit

git-commit:
	sudo git add .
	sudo git commit -m "configgyuuu"
