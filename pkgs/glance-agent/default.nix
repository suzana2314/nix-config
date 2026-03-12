{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "glance-agent";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "agent";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eNhOelHR3EB3RWWMe7fG6vklgADX7XFy6QMI4Lfr8oM=";
  };

  vendorHash = "sha256-vjcyZctfgnAhzFEF0c+GhtWQqa4gVvLLj0E3sCLS0RE=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/glanceapp/agent/internal/agent.buildVersion=v${finalAttrs.version}"
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  meta = {
    description = "A lightweight service that exposes system metrics via an HTTP API, intended to be used with Glance's server stats widget";
    homepage = "https://github.com/glanceapp/agent";
    license = lib.licenses.gpl3;
    mainProgram = "agent";
  };
})
