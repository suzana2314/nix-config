{
  lib,
  config,
  inputs,
  ...
}:
let
  net = inputs.nix-secrets.networking;
in
{
  options.net = {
    host = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
    };
  };

  config =
    let
      hostname = config.net.host;
      host = net.hosts.${hostname} or null;
    in
    lib.mkIf (host != null) {
      networking = {
        enableIPv6 = false;
        useDHCP = false;
        interfaces.${host.interface}.ipv4.addresses = [
          {
            address = host.ip;
            prefixLength = net.prefixLength;
          }
        ];
        defaultGateway = net.gateway;
        nameservers = host.dns;
        firewall.enable = true;
      };
    };
}
