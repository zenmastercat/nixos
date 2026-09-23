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
	nix-collect-garbage -d
