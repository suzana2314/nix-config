# inspired by: https://github.com/geier/khal_gruvbox
{ config, ... }:
let
  inherit (config.colorScheme) palette;
  bg0 = "#${palette.base00}";
  bg1 = "#${palette.base01}";
  bg2 = "#${palette.base02}";
  bg4 = "#${palette.base03}";
  fg0 = "#${palette.base07}";
  fg1 = "#${palette.base06}";
  aqua = "#${palette.base0C}";
  blue = "#${palette.base0D}";
  red = "#${palette.base08}";
  yellow = "#${palette.base0A}";
in
{
  programs.khal.settings.palette = {
    header = "'', '', '', '${yellow}', '${bg0}'";
    footer = "'', '', '', '${bg1}', '${bg0}'";
    bright = "'dark blue', 'white', 'bold,standout'";
    list = "'black', 'white'";
    "list focused" = "'white', 'light blue', 'bold'";
    edit = "'', '', '', '${blue}', '${bg1}'";
    "edit focus" = "'', '', '', '${yellow}', '${bg2}'";
    button = "'', '', '', 'bold,${yellow}', '${bg1}'";
    "button focused" = "'white', 'light blue', 'bold'";

    "reveal focus" = "'', '', 'bold', '${yellow}', '${bg0}'";
    "today focus" = "'', '', '', 'bold,${bg0}', '${red}'";
    today = "'', '', '', 'bold,${red}', '${bg0}'";

    "date header" = "'', '', '', '${bg4}', '${bg0}'";
    "date header focused" = "'', '', '', 'bold,${aqua}', '${bg0}'";
    "date header selected" = "'', '', '', 'bold,${aqua}', '${bg0}'";

    dayname = "'', '', '', 'bold,${aqua}', '${bg0}'";
    monthname = "'', '', '', 'bold,${aqua}', '${bg0}'";
    weeknumber_right = "'', '', '', '${red}', '${yellow}'";
    mark = "'', '', '', '${red}', '${bg0}'";
    frame = "'', '', '', '${bg1}', '${bg0}'";
    "frame focus" = "'', '', '', '${yellow}', '${bg0}'";
    "frame focus color" = "'', '', '', '${red}', '${bg0}'";
    "frame focus top" = "'', '', '', '${bg1}', '${bg0}'";

    eventcolumn = "'', '', '', '${fg0}', '${bg0}'";
    "eventcolumn focus" = "'', '', '', '${fg0}', '${bg0}'";
    calendar = "'', '', '', '${fg1}', '${bg0}'";
    "calendar focus" = "'', '', '', '${fg1}', '${bg0}'";

    editor = "'', '', '', '${fg1}', '${bg0}'";
    "editor focus" = "'', '', '', '${fg1}', '${bg0}'";
    editbx = "'', '', '', '${red}', '${yellow}'";
    editcp = "'', '', '', '${red}', '${yellow}'";
    popupbg = "'', '', 'bold', '${fg1}', '${bg1}'";
    popupper = "'', '', '', '${blue}', '${bg1}'";
    caption = "'', '', 'bold', 'bold,${fg1}', '${bg0}'";
  };
}
