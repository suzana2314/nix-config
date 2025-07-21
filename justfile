default:
  @just --list

[group('dev')]
diff:
  git diff ':!flake.lock'

[group('dev')]
check:
  nix flake check

[group('dev')]
format:
  nixpkgs-fmt .

[group('nix')]
up:
  nix flake update

[group('nix')]
verify:
  nix store verify --all

[group('nix')]
gc:
  sudo nix-collect-garbage -d

[group('build')]
build:
  # sudo nixos-rebuild switch --flake .#master --show-trace --verbose
  nh os switch .#nixosConfigurations.master --ask

[group('build')]
build-boot:
  sudo nixos-rebuild boot --flake .#master --show-trace --verbose

[group('deploy')]
sync $host:
  rsync -ax --delete --rsync-path="sudo rsync" ./ {{host}}:/etc/nixos/

[group('deploy')]
deploy $host:
  just sync {{ host }}; nixos-rebuild switch --flake .#{{host}} --target-host {{host}} --build-host {{host}} --fast --use-remote-sudo --show-trace

