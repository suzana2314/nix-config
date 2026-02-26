{ config, ... }:
{
  yubikey = {
    enable = true;
    user = config.users.users.suz.name;
    identifiers = {
      astral = 36622978;
      lunarium = 36622976;
    };
  };
}
