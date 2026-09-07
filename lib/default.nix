{ lib }:
let
  hexToInt =
    hex:
    let
      digits = {
        "0" = 0;
        "1" = 1;
        "2" = 2;
        "3" = 3;
        "4" = 4;
        "5" = 5;
        "6" = 6;
        "7" = 7;
        "8" = 8;
        "9" = 9;
        "a" = 10;
        "b" = 11;
        "c" = 12;
        "d" = 13;
        "e" = 14;
        "f" = 15;
      };
      hi = builtins.substring 0 1 hex;
      lo = builtins.substring 1 1 hex;
    in
    digits.${hi} * 16 + digits.${lo};

  hexToRgb =
    hex:
    let
      stripped = lib.removePrefix "#" hex;
      r = hexToInt (builtins.substring 0 2 stripped);
      g = hexToInt (builtins.substring 2 2 stripped);
      b = hexToInt (builtins.substring 4 2 stripped);
    in
    "${toString r}, ${toString g}, ${toString b}";
in
{
  inherit hexToInt hexToRgb;
}
