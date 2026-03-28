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
  nh os switch .#nixosConfigurations.master --ask

[group('deploy')]
sync $host:
  rsync -ax --delete ./ {{host}}:$XDG_CONFIG_HOME/nix/

[group('deploy')]
deploy $host: (sync host)
  nixos-rebuild-ng switch --flake .#{{host}} --target-host {{host}} --no-reexec --sudo
