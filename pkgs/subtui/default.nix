{
  lib,
  pkgs,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "subtui";
  version = "2.13.0";

  src = fetchFromGitHub {
    owner = "MattiaPun";
    repo = "subtui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wm/EtDZTJH6IqsbMEsE/4UOWS7/qQTuWNIKSdCmpPlg=";
  };

  vendorHash = "sha256-LSEp0NaNsdnpDZTDUvpK5L7yPlqt3/W4jI9OOnvo7Lc=";

  nativeBuildInputs = [ pkgs.makeWrapper ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${finalAttrs.version}"
    "-X main.commit=${finalAttrs.src.rev}"
  ];

  postInstall = ''
    mv $out/bin/SubTUI $out/bin/subtui
  '';

  postFixup = ''
    wrapProgram $out/bin/subtui \
      --prefix PATH : ${lib.makeBinPath [ pkgs.mpv ]}
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "-v";
  doInstallCheck = true;

  meta = {
    description = "Lightweight Subsonic TUI music player with scrobbling support";
    homepage = "https://github.com/MattiaPun/SubTUI";
    license = lib.licenses.mit;
    mainProgram = "subtui";
  };
})
