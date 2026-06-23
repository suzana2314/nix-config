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
update $pkg:
  nix-update --flake --commit {{pkg}}

[group('nix')]
verify:
  nix store verify --all

[group('nix')]
gc:
  sudo nix-collect-garbage -d

[group('build')]
build:
  nh os switch .#nixosConfigurations.$(hostname) --ask

[group('build')]
iso:
  rm -rf result
  nix build .#nixosConfigurations.iso.config.system.build.isoImage

[group('build')]
iso-flash DRIVE:
  just iso
  sudo dd if=$(ls -t result/iso/*.iso | head -n1) of=/dev/sda bs=4M status=progress oflag=sync

[group('deploy')]
sync $host:
  rsync -ax --delete ./ {{host}}:$XDG_CONFIG_HOME/nix/

[group('deploy')]
deploy $host: (sync host)
  nixos-rebuild switch --flake .#{{host}} --target-host {{host}} --no-reexec --sudo
