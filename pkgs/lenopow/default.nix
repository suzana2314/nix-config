{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "lenopow";
  version = "1.0.4";

  src = pkgs.fetchFromGitHub {
    owner = "makifdb";
    repo = "lenopow";
    rev = "8671800bb2345e5a688bdbc5c1ea7cd4ebba21dd";
    sha256 = "sha256-P7yQ2bxUQ+uiQiGeA5BGnm+Ws7wss/fzyHJ8LkCaKH4=";
  };

  buildPhase = ''
    echo "Skipping build, nothing to compile."
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -m755 lenopow $out/bin/lenopow
  '';

  meta = {
    description = "A script to manage Lenovo laptop power settings";
    homepage = "https://github.com/makifdb/lenopow";
    license = pkgs.lib.licenses.unlicense;
    maintainers = with pkgs.lib.maintainers; [ ];
  };
}
