# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Personal dotfiles managed by [dotbot](https://github.com/anishathalye/dotbot) (forked to `ajay/dotbot`) with a Make-based build system. Targets Fedora Linux with GNOME desktop.

> ⚠️ **This repo is PUBLIC on GitHub.** Keep employer-internal content out of tracked files **and** commit messages — no internal hostnames, service names, ticket or review numbers, or internal paths. Anything sensitive belongs in the `private` submodule, which is where the Claude config already lives. When in doubt, put it in `private`.

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
- `shell-nvidia` — install the NVIDIA driver (akmod-nvidia + CUDA) on machines with an NVIDIA GPU; no-op otherwise
- `shell-jlink` — install the SEGGER J-Link RPM (downloaded from segger.com, not in any repo); skipped if already present
- `shell-udev` — deploy `dotfiles/udev/*.rules` to `/etc/udev/rules.d`, reload, and warn about unmerged `.rpmnew` files; skipped on Meta machines, where Chef owns that directory
- `shell-insync` — install Insync (Google Drive sync)
- `shell-pip` — install Python packages from `scripts/requirements.txt`
- `shell-gnome-extensions` — install GNOME extensions (V-Shell, Tactile, Caffeine, Vitals)
- `shell-gnome-extension-settings` — configure GNOME extension dconf settings
- `shell-gsettings-tweaks` — minor gsettings overrides (titlebar buttons, middle-click paste)
- `shell-chsh` — set default shell to fish
- `shell-gsettings` — GNOME desktop settings (dark mode, workspaces, clock, dock favorites)
- `shell-keybindings` — keyboard shortcuts (Alt+Tab window switching, Ctrl+Alt+T terminal)
- `shell-gdm` — deploy `/etc/gdm/custom.conf` via `sudo install`
- `shell-timezone` — set timezone to America/Los_Angeles
- `shell-wallpaper` — set desktop wallpaper
- `shell-meta-chef` — run Meta chef (soloctl)
- `shell-meta-eden` — on Meta machines, clear the `fedora_eden.service` (EdenFS) failed state so GNOME stops showing its "Application Stopped" notification; no-op elsewhere

Steps can be skipped with `--except` flags (used by install-dev/lite/no-chef targets).

**dotbot plugins** (loaded via `--plugin` flags in Makefile):
- `dotbot/plugins/dotbot-directive/` — vendored (not a submodule). Wraps arbitrary directive names as skippable groups, so every `shell-*` step in `dotbot.conf.yaml` can be targeted by `--except <name>` / `--only <name>`. This is the mechanism behind install-dev/install-lite/install-no-chef. Also supports per-task `if: <test command>` conditions — `shell-dnf-update` uses `if: test -d /opt/facebook` to branch between Meta (`up-no-meta`) and non-Meta (`update`) flavors.
- `dotbot/plugins/dotbot-pip/` — vendored; pip install from requirements file

## Dotfiles Layout

Files under `dotfiles/` are symlinked to their home-directory locations by dotbot. The mapping is defined in `dotbot.conf.yaml` under the `link` section — only paths listed there are linked. Claude Code config lives in the `private` submodule, not the public tree: `private/dotfiles/claude/settings.json` and `settings.local.json` are symlinked to `~/.claude/`, `private/dotfiles/claude/CLAUDE.md` to `~/.claude/CLAUDE.md` (the user-level session guide), `private/dotfiles/claude/commands/` to `~/.claude/commands/`, and `private/dotfiles/claude/memory/` to `~/.claude/projects/-home-ajaysriv/memory/` (the unified auto-memory store). The commands are custom slash commands: `ajay-init` (read-only session bootstrap), `ajay-inspect-commit` (inspect the current commit/stack), `ajay-ship` (generate a stage/commit/push script), `ajay-handoff` (write cross-machine handoff docs into `.session-handoff/`), `ajay-resume` (resume work from those handoff docs on another machine), `ajay-audit-claude` (audit the whole Claude config and propose fixes as an approve-first plan), `ajay-init-*` project-bootstrap variants, and `ajay-permission-{build,scm}-{allow,deny}` (session-scoped toggles for whether Claude may run build tooling or write to source control).

## udev rules

`dotfiles/udev/` holds only the rules nothing else provides — currently just `51-android.rules` (adb/fastboot: `android-tools` ships no rules and Fedora has no `android-udev-rules` package). Everything else is left to whoever owns it: openocd, stlink and the SEGGER J-Link RPM ship rules with their packages, and Saleae's `99-SaleaeLogic.rules` comes with the Logic 2 download. Don't vendor those here — a copy in this repo would fight the owner's installer on every `make install`.

**`shell-udev` is skipped on Meta machines** (`test ! -d /opt/facebook`). Chef owns `/etc/udev/rules.d` there and rewrites what it manages on every run, so anything this repo wrote would be reverted within the hour — and `51-android.rules` is one of the paths Chef declares. Never hand-edit a rules file on a Meta box either; fix it in the cookbook instead.

Filenames must sort before `73-seat-late.rules`, which is where `TAG+="uaccess"` is turned into an ACL — a tag set by a later-sorting file is never acted on. Every uaccess-granting rule Fedora ships obeys this (`60-libjaylink`, `60-openocd`, `69-libftdi`, `70-uaccess`, `71-seat`).

Rules are copied by `shell-udev`, not symlinked: dotbot's `link:` runs unprivileged and cannot write to root-owned `/etc`, rules must be readable at boot before `$HOME` is necessarily available, and on an SELinux-enforcing machine a symlink into `$HOME` resolves to a `user_home_t` file that confined udev is denied.

## Identity split: git vs hg

`dotfiles/git/gitconfig` uses the personal address (`ajaysriv3@gmail.com`); `dotfiles/hg/hgrc` uses the Meta address (`ajaysriv@meta.com`). This is deliberate — git is for the `ajay/*` GitHub repos (dotfiles, build-tools, sites), hg is for fbsource. Don't unify them.

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

See `.gitmodules` for the canonical list. `GIT_SUBMODULE_STALE_CHECK_EXCLUDE := pyyaml private` in the Makefile excludes pyyaml (a dotbot transitive dependency) and `private` (CI doesn't fetch the private submodule) from the CI staleness check.
