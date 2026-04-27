################################################################################

# Copied from build-tools git.mk reference implementation.
# https://github.com/ajay/build-tools/blob/main/makefiles/git.mk
# Keep in sync with the reference when updating.

REPO_ROOT := $(shell git rev-parse --show-toplevel)

git-submodule-update:
	@## initialize and update git submodules
	git pull
	git submodule sync --recursive
	git submodule update --init --recursive

ifneq ($(filter git-submodule-update install,$(MAKECMDGOALS)),)
else ifneq (,$(shell git submodule status --recursive 2>/dev/null | grep '^[-+]'))
$(error ERROR: git submodules not initialized or out of date; run `make git-submodule-update`)
endif

################################################################################

-include $(REPO_ROOT)/tools/build-tools/makefiles.mk

################################################################################

DEPS += python3

GIT_SUBMODULE_STALE_CHECK_EXCLUDE := pyyaml

DOTBOT_BIN           := dotbot/dotbot/bin/dotbot
DOTBOT_CONFIG        := dotbot.conf.yaml
DOTBOT_FLAGS_PLUGINS := \
	--plugin dotbot/plugins/dotbot-directive/directive.py \
	--plugin dotbot/plugins/dotbot-pip/pip.py
DOTBOT_FLAGS_EXTRA   :=

ci: git-check deps-check deps-versions lint
	@## run CI checks

install: git-submodule-update
	@## install dotfiles
	python3 -B $(DOTBOT_BIN)           \
		--base-directory $(CURDIR)     \
		--config-file $(DOTBOT_CONFIG) \
		$(DOTBOT_FLAGS_PLUGINS)        \
		$(DOTBOT_FLAGS_EXTRA)          \
		-vv

install-dev:
	@## install (install-lite + skip shell-git)
	$(MAKE) install DOTBOT_FLAGS_EXTRA="--except shell-sudo shell-build-tools-deps shell-dnf shell-meta-chef shell-git"

install-lite:
	@## install (skip shell-sudo shell-build-tools-deps shell-dnf shell-meta-chef)
	$(MAKE) install DOTBOT_FLAGS_EXTRA="--except shell-sudo shell-build-tools-deps shell-dnf shell-meta-chef"

install-no-chef:
	@## install (skip shell-meta-chef)
	$(MAKE) install DOTBOT_FLAGS_EXTRA="--except shell-meta-chef"

################################################################################
