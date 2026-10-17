{ config }:
{
  homeassistant = {
    hashedPasswordFile = config.sops.secrets."mqtt/homeassistant".path;
    acl = [ "readwrite #" ];
  };
  frigate = {
    hashedPasswordFile = config.sops.secrets."mqtt/frigate".path;
    acl = [
      "readwrite frigate/#"
    ];
  };
}
