<div align="center">
<h1>
<img width="200" src="https://github.com/NixOS/nixos-artwork/blob/master/logo/nix-snowflake-colours.svg" />
<br>
Nix Config
</h1>
</div>

## Overview

This repository contains my personal NixOS system configurations. It's not meant to be a ready-to-use solution that you can deploy on any machine. Instead, think of it as a reference where you can get ideas and see how things can be done for your own setup.

## Managed Systems

- **master** - my main machine
- **byrgenwerth** - media server
- **hemwick** - smart home / DNS server / lightweight apps
- **yahargul** - offsite server (not currently in use)

## Key Features

This repo uses flakes for reproducible system configurations. The setup includes:

- Stable base system packages and unstable for most everyday apps
- Home manager for managing users and dotfiles
- Hardware specific configurations using nixos-hardware
- Disk setup with disko

## Secrets Management

Secrets are managed using sops-nix and kept in a separate private repository where everything is encrypted. The private repository holds both "hard" secrets and less sensitive config data, "soft" secrets.

## Automated Updates

*(This section is currently experimental and might change)*

The repo has a semi-auto update system
- GitHub action runs every Saturday to update the flake lock file;
- Some hosts (byrgenwerth and hemwick) have a cron job that fetches the new lock file and updates the system;
- It then sends me a notification with the system status (so I know if anything breaks);

## Dev Workflow
Pre-commit hooks and some automated checks help catch some issues before they make it into the config and repo. A dev shell provides all the tools needed to make changes.
I use [just](https://github.com/casey/just) to run lengthy commands with some helpful recipes for common tasks.

## References

- [EmergentMind](https://github.com/EmergentMind/nix-config) - Great config and secrets management (where I got the idea from)
- [notthebee](https://github.com/notthebee/nix-config/) - Another great config with focus on selfhosting
- [Misterio77](https://github.com/Misterio77/nix-starter-configs) - My config structure reference of choice
- [VimJoyer](https://github.com/vimjoyer) - Awesome videos and the one that got me into NixOS
