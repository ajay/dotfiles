# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Personal dotfiles managed by [dotbot](https://github.com/anishathalye/dotbot) (forked to `ajay/dotbot`) with a Make-based build system. Targets Fedora Linux with GNOME desktop.

## Commands

```bash
make install              # Install dotfiles (runs dotbot: symlinks, packages, pip, chef)
make install-dev          # Install without dnf, chef, git, sudo steps
make install-lite         # Install without dnf, chef, sudo
make install-no-chef      # Install without chef
make ci                   # Run CI checks (git-check, deps-check, deps-versions, lint)
make git-submodule-update # Initialize and update all git submodules
make help                 # List all available Make targets
```

Submodules must be initialized before any target other than `git-submodule-update` — the Makefile enforces this with an error if they're stale.

## Architecture

**Makefile** is the entry point. It copies the submodule-check boilerplate from `tools/build-tools/makefiles/git.mk` (keep in sync manually), then includes all build-tools makefiles via `tools/build-tools/makefiles.mk`. Build-tools provides shared targets: `git-check`, `deps-check`, `deps-versions`, `lint`, `help`, etc.

**dotbot.conf.yaml** defines the install pipeline as ordered steps:
1. `defaults` — link settings (backup, create, relink)
2. `shell-sudo` — cache sudo
3. `shell-git` — pull, update submodules, check clean
4. `clean` — ensure target directories exist
5. `link` — symlink dotfiles to home directory
6. `shell-dnf` — install/update Fedora packages
7. `shell-pip` — install Python packages from `scripts/requirements.txt`
8. `shell-meta-chef` — run Meta chef (soloctl)

Steps can be skipped with `--except` flags (used by install-dev/lite/no-chef targets).

**dotbot plugins** (loaded via `--plugin` flags in Makefile):
- `dotbot-directive` — custom dotbot directive support
- `dotbot-pip` — pip install from requirements file

## Dotfiles Layout

Files under `dotfiles/` are symlinked to their home-directory locations by dotbot. The mapping is defined in `dotbot.conf.yaml` under the `link` section.

## Scripts

Scripts in `scripts/` are symlinked to `~/.local/bin/` and prefixed with `ajay-`:

- **ajay-github-repo-manager** — Python TUI (Textual) that shows GitHub repo status: HEAD commit, CI workflow results, and submodule staleness across all repos listed in `REPOS`. Uses GitHub API via `gh auth token`. Add/remove repos by editing the `REPOS` list.
- **ajay-workspace-setup** — Bash script that launches apps and tiles windows across GNOME workspaces using a custom D-Bus GNOME Shell extension. Edit the `LAYOUT` array to change the workspace configuration.

## CI

GitHub Actions workflow (`.github/workflows/make-ci.yml`) runs `make ci` on push to master and daily at midnight. Uses the reusable workflow from `ajay/build-tools`.

## Submodules

- `dotbot/dotbot` — forked dotbot (`ajay/dotbot`)
- `dotbot/plugins/dotbot-pip` — pip plugin (`sobolevn/dotbot-pip`)
- `tools/build-tools` — shared Make infrastructure (`ajay/build-tools`)

`GIT_SUBMODULE_STALE_CHECK_EXCLUDE := pyyaml` in the Makefile excludes pyyaml (a dotbot transitive dependency) from the CI staleness check.
