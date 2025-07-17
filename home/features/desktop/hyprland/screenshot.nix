{ pkgs, ... }:
let
  screenshot-pkg = pkgs.writeShellApplication {
    name = "screenshot-tool";
    runtimeInputs = [ pkgs.libnotify pkgs.slurp pkgs.wl-clipboard pkgs.grim ];
    text = ''
      TMPFILE=$(mktemp /tmp/temp-screenshot-XXXXXX.png)
    
      grim -g "$(slurp -d -b 1a1a1a77 -w 0)" "$TMPFILE"
    
      wl-copy < "$TMPFILE"
    
      notify-send "Screenshot" "Area screenshot copied to clipboard" -i "$TMPFILE"
    
      (sleep 5 && rm "$TMPFILE") &
    '';
  };
in
{
  home.packages = [
    screenshot-pkg
  ];
}
