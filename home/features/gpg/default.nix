{ config, pkgs, ... }:
{

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
    publicKeys = [
      {
        source = ../../../machines/common/users/super/keys/pgp.asc;
        trust = 5;
      }
    ];

    scdaemonSettings = {
      disable-ccid = true;
    };

    settings = {
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
      cert-digest-algo = "SHA512";
      s2k-digest-algo = "SHA512";
      s2k-cipher-algo = "AES256";
      charset = "utf-8";
      fixed-list-mode = true;
      no-comments = true;
      no-emit-version = true;
      no-greeting = true;
      keyid-format = "0xlong";
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity";
      with-fingerprint = true;
      require-cross-certification = true;
      require-secmem = true;
      no-symkey-cache = true;
      armor = true;
      use-agent = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-tty;
    enableZshIntegration = true;
  };

}
