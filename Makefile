DOTBOT_BIN           := dotbot/dotbot/bin/dotbot
DOTBOT_CONFIG        := dotbot.conf.yaml
DOTBOT_FLAGS_PLUGINS := --plugin dotbot/plugins/dotbot-directive/directive.py \
                       --plugin dotbot/plugins/dotbot-pip/pip.py
DOTBOT_FLAGS_EXTRA   :=

.PHONY: git-submodule-update install install-lite install-no-chef

git-submodule-update:
	git pull
	git submodule sync --recursive
	git submodule update --init --recursive

install: git-submodule-update
	python3 -B $(DOTBOT_BIN)           \
		--base-directory $(CURDIR)     \
		--config-file $(DOTBOT_CONFIG) \
		$(DOTBOT_FLAGS_PLUGINS)        \
		$(DOTBOT_FLAGS_EXTRA)          \
		-vv

install-lite:
	$(MAKE) install DOTBOT_FLAGS_EXTRA="--except shell-dnf shell-meta-chef shell-sudo"

install-no-chef:
	$(MAKE) install DOTBOT_FLAGS_EXTRA="--except shell-meta-chef"
