{
  inputs,
  pkgs,
  config,
  ...
}:
{
  imports = [
    inputs.stylix.homeModules.stylix
  ];
  stylix = {
    enable = true;
    base16Scheme = config.colorTheme;
    autoEnable = false;
    enableReleaseChecks = false;
    targets = {
      gtk = {
        enable = true;
        fonts.enable = false;
      };
      qt = {
        enable = true;
        standardDialogs = "xdgdesktopportal";
      };
    };
  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.quintom-cursor-theme;
      name = "Quintom_Ink";
      size = 16;
    };
    iconTheme = {
      package = pkgs.gruvbox-plus-icons.override { folder-color = "grey"; };
      name = "Gruvbox-Plus-Dark";
    };
  };
}
