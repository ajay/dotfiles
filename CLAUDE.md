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
make git-submodule-update # git pull, then initialize and update all git submodules
make help                 # List all available Make targets
```

Only `make install` and `make git-submodule-update` auto-update submodules (and both run `git pull` first). All other targets — including `install-dev`/`install-lite`/`install-no-chef` and `ci` — error out if submodules are stale.

## Architecture

**Makefile** is the entry point. It copies the submodule-check boilerplate from `tools/build-tools/makefiles/git.mk` (keep in sync manually), then includes all build-tools makefiles via `tools/build-tools/makefiles.mk`. Build-tools provides shared targets: `git-check`, `deps-check`, `deps-versions`, `lint`, `help`, etc.

**dotbot.conf.yaml** defines the install pipeline as ordered steps:
0. `defaults` — link settings (backup, create, relink)
0. `shell-sudo` — cache sudo
0. `shell-git` — pull, update submodules, check clean
0. `clean` — ensure target directories exist
0. `link` — symlink dotfiles to home directory
0. `shell-build-tools-deps` — `make -C tools/build-tools deps-install`
0. `shell-dnf` — install/update Fedora packages
0. `shell-pip` — install Python packages from `scripts/requirements.txt`
0. `shell-meta-chef` — run Meta chef (soloctl)

Steps can be skipped with `--except` flags (used by install-dev/lite/no-chef targets).

**dotbot plugins** (loaded via `--plugin` flags in Makefile):
- `dotbot/plugins/dotbot-directive/` — vendored (not a submodule); see `directive.py` for the directives it adds
- `dotbot/plugins/dotbot-pip/` — submodule; pip install from requirements file

## Dotfiles Layout

Files under `dotfiles/` are symlinked to their home-directory locations by dotbot. The mapping is defined in `dotbot.conf.yaml` under the `link` section.

## Scripts

Scripts in `scripts/` are symlinked to `~/.local/bin/` and prefixed with `ajay-`. Add/remove repos or layouts by editing the lists at the top of each script.

## CI

GitHub Actions workflow (`.github/workflows/make-ci.yml`) runs `make ci` on push to master and daily at midnight. Uses the reusable workflow from `ajay/build-tools`.

## Submodules

See `.gitmodules` for the canonical list. `GIT_SUBMODULE_STALE_CHECK_EXCLUDE := pyyaml` in the Makefile excludes pyyaml (a dotbot transitive dependency) from the CI staleness check.
