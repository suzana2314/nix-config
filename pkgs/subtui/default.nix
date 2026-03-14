{
  lib,
  pkgs,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "subtui";
  version = "2.11.1";

  src = fetchFromGitHub {
    owner = "MattiaPun";
    repo = "subtui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xe1HTF6wC1+GUVKCO5AuFD9kThfY1YUjL74TYVyAvIU=";
  };

  vendorHash = "sha256-LSEp0NaNsdnpDZTDUvpK5L7yPlqt3/W4jI9OOnvo7Lc=";

  nativeBuildInputs = [ pkgs.makeWrapper ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${finalAttrs.version}"
    "-X main.commit=${finalAttrs.src.rev}"
  ];

  postFixup = ''
    wrapProgram $out/bin/SubTUI \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.mpv ]}
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "-v";
  doInstallCheck = true;

  meta = {
    description = "A lightweight Subsonic TUI music player built in Go with scrobbling support.";
    homepage = "https://github.com/MattiaPun/SubTUI";
    license = lib.licenses.mit;
    mainProgram = "SubTUI";
  };
})
