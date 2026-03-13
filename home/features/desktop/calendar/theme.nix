let

  # TODO: Use palette here!
  bg0 = "#1d2021";
  bg1 = "#282828";
  bg2 = "#504945";
  bg3 = "#665c54";
  bg4 = "#7c6f64";
  fg0 = "#fbf1c7";
  fg1 = "#ebdbb2";
  fg2 = "#d5c4a1";
  fg4 = "#a89984";
  neutral_blue = "#458588";
  faded_aqua = "#427b58";
  faded_red = "#9d0006";
in
{
  programs.khal.settings.palette = {
    header = "'', '', '', '${fg1}', '${bg2}'";
    footer = "'', '', '', '${fg1}', '${bg2}'";
    "line header" = "'black', 'white', 'bold'";
    "alt header" = "'white', '', 'bold'";
    bright = "'dark blue', 'white', 'bold,standout'";
    list = "'', ''";
    "list focused" = "'white', 'light blue', 'bold'";
    edit = "'', '', '', '${fg1}', '${bg2}'";
    "edit focus" = "'', '', '', '${fg1}', '${bg3}'";
    button = "'', '', '', '${bg1}', '${neutral_blue}'";
    "button focused" = "'white', 'light blue', 'bold'";
    "reveal focus" = "'', '', 'bold', '${fg0}', '${bg1}'";
    "today focus" = "'white', 'dark magenta'";
    today = "'dark gray', 'dark green'";
    "date header" = "'', '', '', '${fg1}', '${bg1}'";
    "date header focused" = "'', '', '', '${fg0}', '${bg4}'";
    "date header selected" = "'', '', '', '${fg2}', '${bg2}'";
    dayname = "'', '', '', '${fg1},bold', '${bg0}'";
    monthname = "'', '', '', '${fg1},bold', '${bg0}'";
    weeknumber_right = "'', '', '', '${fg4}', '${bg0}'";
    weeknumber_left = "'', ''";
    alert = "'', ''";
    mark = "'', '', '', '${fg0}', '${faded_aqua}'";
    frame = "'', '', '', '${fg4}', '${bg0}'";
    "frame focus" = "'', '', '', '${faded_aqua}', '${bg0}'";
    "frame focus color" = "'', '', '', '${faded_red}', '${bg0}'";
    "frame focus top" = "'', '', '', '${fg2}', '${bg0}'";
    eventcolumn = "'', '', '', '${fg0}', '${bg0}'";
    "eventcolumn focus" = "'', '', '', '${fg0}', '${bg0}'";
    calendar = "'', '', '', '${fg1}', '${bg0}'";
    "calendar focus" = "'', '', '', '${fg1}', '${bg0}'";
    editor = "'', '', '', '${fg1}', '${bg0}'";
    "editor focus" = "'', '', '', '${fg1}', '${bg0}'";
    editbx = "'light gray', 'dark blue'";
    editcp = "'black', 'light gray', 'standout'";
    popupbg = "'white', 'black', 'bold'";
    popupper = "'white', 'dark cyan'";
    caption = "'', '', 'bold', '${fg1},bold', '${bg0}'";
  };
}
