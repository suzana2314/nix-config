{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "sqldeveloper";
  version = "1.0";

  src = pkgs.fetchzip {
    url = "https://download.oracle.com/otn_software/java/sqldeveloper/sqldeveloper-24.3.1.347.1826-no-jre.zip";
    stripRoot = false;
    hash = "sha256-ju6BYdiy+Fpdq5+mEMBOOEWwuZlqgTxdhXvtnT0HT3E=";
  };

  nativeBuildInputs = [
    pkgs.makeWrapper
  ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out;
    cp -r $src/* $out
    mkdir -p $out/bin
    cat > $out/bin/sqldeveloper <<EOF
    #!${pkgs.runtimeShell}
    exec bash $out/sqldeveloper/sqldeveloper/bin/sqldeveloper
    EOF
    chmod +x $out/bin/sqldeveloper
  '';
}
