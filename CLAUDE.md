# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Personal dotfiles managed by [dotbot](https://github.com/anishathalye/dotbot) (forked to `ajay/dotbot`) with a Make-based build system. Targets Fedora Linux with GNOME desktop.

## Commands

```bash
make install              # install dotfiles (runs git pull + submodule update, then dotbot)
make install-dev          # install (install-lite + skip shell-git)
make install-lite         # install (skip shell-build-tools-deps shell-dnf-update shell-meta-chef)
make install-no-chef      # install (skip shell-meta-chef)
make ci                   # run CI checks (git-check, deps-check, deps-versions, lint)
make lint                 # check formatting + run linters (prettier + htmlhint; HTML/CSS/JS/JSON only)
make format               # auto-format files in place (prettier --write)
make git-submodule-update # initialize and update git submodules (also runs git pull)
make help                 # this menu
```

Only `make install` and `make git-submodule-update` auto-update submodules (and both run `git pull` first). All other targets — including `install-dev`/`install-lite`/`install-no-chef` and `ci` — error out if submodules are stale.

## Architecture

**Makefile** is the entry point. It copies the submodule-check boilerplate from `tools/build-tools/makefiles/git.mk` (keep in sync manually), then includes all build-tools makefiles via `tools/build-tools/makefiles.mk`. Build-tools provides shared targets: `git-check`, `deps-check`, `deps-versions`, `lint`, `help`, etc.

**dotbot.conf.yaml** defines the install pipeline as ordered steps:
- `defaults` — link settings (backup, create, relink)
- `shell-sudo` — cache sudo
- `shell-git` — pull, update submodules, check clean
- `clean` — ensure target directories exist
- `link` — symlink dotfiles to home directory
- `shell-build-tools-deps` — `make -C tools/build-tools deps-install`
- `shell-dnf-update` — `dnf update` (Meta-aware: uses `up-no-meta` on Meta machines)
- `shell-dnf` — install Fedora packages
- `shell-insync` — install Insync (Google Drive sync)
- `shell-pip` — install Python packages from `scripts/requirements.txt`
- `shell-gnome-extensions` — install GNOME extensions (V-Shell, Tactile, Caffeine, Vitals)
- `shell-gnome-extension-settings` — configure GNOME extension dconf settings
- `shell-gsettings-tweaks` — minor gsettings overrides (titlebar buttons, middle-click paste)
- `shell-chsh` — set default shell to fish
- `shell-gsettings` — GNOME desktop settings (dark mode, workspaces, clock, dock favorites)
- `shell-keybindings` — keyboard shortcuts (Alt+Tab window switching, Ctrl+Alt+T terminal)
- `shell-timezone` — set timezone to America/Los_Angeles
- `shell-wallpaper` — set desktop wallpaper
- `shell-meta-chef` — run Meta chef (soloctl)

Steps can be skipped with `--except` flags (used by install-dev/lite/no-chef targets).

**dotbot plugins** (loaded via `--plugin` flags in Makefile):
- `dotbot/plugins/dotbot-directive/` — vendored (not a submodule). Wraps arbitrary directive names as skippable groups, so every `shell-*` step in `dotbot.conf.yaml` can be targeted by `--except <name>` / `--only <name>`. This is the mechanism behind install-dev/install-lite/install-no-chef.
- `dotbot/plugins/dotbot-pip/` — vendored; pip install from requirements file

## Dotfiles Layout

Files under `dotfiles/` are symlinked to their home-directory locations by dotbot. The mapping is defined in `dotbot.conf.yaml` under the `link` section — only paths listed there are linked. Notably, `dotfiles/claude/settings.json` is intentionally not symlinked; the `claude` fish function passes it via `--settings`, so it acts as the user-layer settings for fish-launched Claude Code sessions. `dotfiles/claude/commands/` is symlinked to `~/.claude/commands/` and contains custom slash commands (ajay-flockboss, ajay-inspect-commit, ajay-ship).

## Scripts

Scripts symlinked to `~/.local/bin/` are listed individually under `link` in `dotbot.conf.yaml` (each prefixed `ajay-`). Other files in `scripts/` (e.g. `requirements.txt`, `scm-prompt-echo.sh`) are consumed in place, not linked. Per-script config — repo lists for `ajay-github-*`, monitor/workspace layouts for `ajay-workspace-setup` — lives at the top of each script.

## Docs

- `docs/TODO.md` — tracks pending dotfile work. Append to `# TODO`; move items to `# Done` when shipped.
- `docs/fresh_install.md` — step-by-step guide for setting up a new Fedora machine (BIOS, dual-boot, post-install).

## Commit messages

Format: `<area>[: <subarea>...]: <change>` — lowercase, imperative, no period. `area` is the top-level subdirectory or script name (e.g., `dotfiles: fish: functions: add maui-skoobe-dhara wrapper`, `ajay-workspace-setup: fix Wayland cross-monitor window placement`, `dotbot.conf.yaml: introduce shell-misc`).

## CI

GitHub Actions workflow (`.github/workflows/make-ci.yml`) runs `make ci` on push to master and daily at midnight. Uses the reusable workflow from `ajay/build-tools`.

## Submodules

See `.gitmodules` for the canonical list. `GIT_SUBMODULE_STALE_CHECK_EXCLUDE := pyyaml` in the Makefile excludes pyyaml (a dotbot transitive dependency) from the CI staleness check.
