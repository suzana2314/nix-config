default:
  @just --list

[group('nix')]
up:
  nix flake update

[group('nix')]
verify:
  nix store verify --all

[group('nix')]
build-host HOST:
  nixos-rebuild --flake .#"{{HOST}}" --target-host {{HOST}} --fast switch --use-remote-sudo --show-trace

[group('nix')]
build:
  sudo nixos-rebuild switch --flake .#master --show-trace --verbose
