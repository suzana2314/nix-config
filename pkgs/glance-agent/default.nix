{ pkgs }:

pkgs.buildGoModule {
  pname = "glance-agent";
  version = "1.0";

  src = pkgs.fetchFromGitHub {
    owner = "suzana2314";
    repo = "glance-agent";
    rev = "b54abbd7e9cf23b792091825a1f980c1ae38d336";
    sha256 = "sha256-kBqEMEwtaI6wK0+fESD4/DwuxQhW5y8xNrx0NkVgOGw=";
  };

  vendorHash = "sha256-o95ZS2qUQfO7DrtfpZriN8cD7JZ1sR9XEJjbZDc3P2c=";

  subPackages = [ "cmd/glance-agent" ];

  ldflags = [
    "-w"
    "-s"
  ];

  env.CGO_ENABLED = "0";

  meta = with pkgs.lib; {
    description = "An endpoint written in Go for the glance server stats widget";
    homepage = "https://github.com/suzana2314/glance-agent";
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
