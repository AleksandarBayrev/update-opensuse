SHELL := /bin/sh

SCRIPT_SRC := update-opensuse
SCRIPT_NAME := update-opensuse
PROJECT_NAME := $(SCRIPT_NAME)
VERSION := $(shell date +%Y%m%d)
RELEASE_ARCHIVE := $(PROJECT_NAME)-$(VERSION).tar.gz

# Writable on MicroOS and suitable for local scripts on Tumbleweed.
INSTALL_DIR := /usr/local/bin

# sudo make install/uninstall targets the invoking user's ~/.alias.
# When running directly as root, override with ALIAS_USER=your_username.
ALIAS_USER ?= $(if $(SUDO_USER),$(SUDO_USER),$(shell id -un))

.DEFAULT_GOAL := help
.PHONY: help install uninstall release clean check-root

help:
	@printf 'Available commands:\n  install\n  uninstall\n  release\n  clean\n'

check-root:
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "Error: Run this target with sudo." >&2; \
		exit 1; \
	fi

install: check-root
	@echo "Installing $(SCRIPT_SRC) to $(INSTALL_DIR)/$(SCRIPT_NAME)..."
	@install -D -m 755 "$(SCRIPT_SRC)" "$(INSTALL_DIR)/$(SCRIPT_NAME)"
	@set -eu; \
	if [ -r /etc/os-release ]; then . /etc/os-release; fi; \
	if [ "$${ID:-}" = "opensuse-microos" ]; then \
		echo "Installing MicroOS alias for $(ALIAS_USER)..."; \
		runuser -u "$(ALIAS_USER)" -- sh -c '\
			set -eu; \
			rc="$$HOME/.alias"; \
			touch "$$rc"; \
			if ! grep -qxF -- "$$1" "$$rc"; then \
				printf "\n%s\n" "$$1" >> "$$rc"; \
			fi' sh 'alias $(SCRIPT_NAME)="sudo $(INSTALL_DIR)/$(SCRIPT_NAME)"'; \
		echo "Open a new Bash terminal or run: source ~/.alias"; \
	else \
		echo "Not MicroOS: skipping alias installation."; \
	fi
	@echo "Install complete."

uninstall: check-root
	@echo "Removing alias for $(ALIAS_USER), if present..."
	@runuser -u "$(ALIAS_USER)" -- sh -c '\
		set -eu; \
		rc="$$HOME/.alias"; \
		if [ -f "$$rc" ]; then \
			sed -i --follow-symlinks \
				"\|^alias $(SCRIPT_NAME)=\"sudo $(INSTALL_DIR)/$(SCRIPT_NAME)\"$$|d" \
				"$$rc"; \
		fi'
	@echo "Removing $(INSTALL_DIR)/$(SCRIPT_NAME)..."
	@rm -f "$(INSTALL_DIR)/$(SCRIPT_NAME)"
	@echo "Uninstall complete."
	@echo "To clear an active alias in this terminal: unalias $(SCRIPT_NAME)"

release:
	@echo "Creating release archive: $(RELEASE_ARCHIVE)"
	@tar -czvf "$(RELEASE_ARCHIVE)" "$(SCRIPT_SRC)" Makefile
	@echo "Release bundle created successfully."

clean:
	@echo "Cleaning up generated release files..."
	@rm -f "$(RELEASE_ARCHIVE)"
	@echo "Cleanup complete."
