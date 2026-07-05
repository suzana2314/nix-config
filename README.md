<div align="center">
<h1>
<img width="300" src="assets/nixos-logo.svg" />
<br>
Nix Config
</h1>
</div>

## Overview

This repository contains my personal NixOS system configurations. It's not meant to be a ready-to-use solution that you can deploy on any machine. Instead, think of it as a reference where you can get ideas and see how things can be done for your own setup. That's why there are not installation instructions.

## Machines

- **master** - my main machine
- **logarius** - thinkpad laptop
- **byrgenwerth** - media server
- **hemwick** - smart home / DNS server / lightweight apps
- **yahargul** - offsite server

## Some Features

- Hardware specific configurations using nixos-hardware
- Disk setup with disko, with encrypted btrfs volumes using LUKS
- Impermanence
- Secure boot
- Full declarative home lab config
- Automated bootstrap using a custom iso image and a really simple python script
- Yubikey for basically everything (ssh, decrypting discs, signing commits, sudo)


## Secrets

Secrets are managed using sops-nix and kept in a separate private repository where everything is encrypted. The private repository holds both "hard" secrets and less sensitive config data, "soft" secrets.

## Structure (so you don't get lost *:)*)
```
.
├── hosts/           # machine configs
├── modules/         # modules for random things + home lab config lives here
├── home/            # home-manager configs
├── pkgs/            # pkgs that are not in nixpkgs
└── flake.nix
```

## References

- [EmergentMind](https://github.com/EmergentMind/nix-config) - Great config and secrets management (where I got the idea from)
- [notthebee](https://git.notthebe.ee/notthebee/nix-config) - Another great config with focus on selfhosting
- [Misterio77](https://github.com/Misterio77/nix-starter-configs) - My config structure reference of choice
- [VimJoyer](https://github.com/vimjoyer) - Awesome videos and the one that got me into NixOS
