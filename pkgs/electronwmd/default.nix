{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "electronwmd";
  version = "0.5.3-1.6.1";

  # unfortunate this had to be an app image because I just could not build the electron app...
  src = fetchurl {
    url = "https://github.com/asivery/ElectronWMD/releases/download/v${version}/electronwmd-${version}-linux_x86_64.AppImage";
    hash = "sha256-IqB+emnXlsyuYNrK4BOsYQ8N+W5z1DZiCWh4hxVZTfU=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/*.desktop -t $out/share/applications
    sed -i 's|^Exec=.*|Exec=${pname} %U|' $out/share/applications/*.desktop
    if [ -d ${appimageContents}/usr/share/icons ]; then
      cp -r ${appimageContents}/usr/share/icons $out/share/
    fi
  '';

  meta = {
    description = "Electron version of Web MiniDisc Pro, for NetMD, Hi-MD and Network Walkman devices";
    homepage = "https://github.com/asivery/ElectronWMD";
    license = lib.licenses.gpl2Only;
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
