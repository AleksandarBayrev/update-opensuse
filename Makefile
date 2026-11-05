SCRIPT_SRC := update-opensuse
SCRIPT_NAME := update-opensuse
PROJECT_NAME := $(SCRIPT_NAME)
VERSION := $(shell date +%Y%m%d)
RELEASE_ARCHIVE := $(PROJECT_NAME)-$(VERSION).tar.gz

# /usr/local/bin is persistent and writable on MicroOS, and is also
# suitable for locally installed scripts on regular Tumbleweed.
INSTALL_DIR := /usr/local/bin

.DEFAULT_GOAL := help
.PHONY: help install uninstall release clean

help:
	@printf 'Available commands:\n  install\n  uninstall\n  release\n  clean\n'

install:
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "Error: This must be run as root. Try 'sudo make install'." >&2; \
		exit 1; \
	fi
	@echo "Installing $(SCRIPT_SRC) to $(INSTALL_DIR)/$(SCRIPT_NAME)..."
	@install -D -m 755 "$(SCRIPT_SRC)" "$(INSTALL_DIR)/$(SCRIPT_NAME)"
	@echo "Install complete."

uninstall:
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "Error: This must be run as root. Try 'sudo make uninstall'." >&2; \
		exit 1; \
	fi
	@echo "Removing $(INSTALL_DIR)/$(SCRIPT_NAME)..."
	@rm -f "$(INSTALL_DIR)/$(SCRIPT_NAME)"
	@echo "Uninstall complete."

release:
	@echo "Creating release archive: $(RELEASE_ARCHIVE)"
	@tar -czvf "$(RELEASE_ARCHIVE)" "$(SCRIPT_SRC)" Makefile
	@echo "Release bundle created successfully."

clean:
	@echo "Cleaning up generated release files..."
	@rm -f "$(RELEASE_ARCHIVE)"
	@echo "Cleanup complete."
