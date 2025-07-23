{
  services.openssh = {
    enable = true;
    openFirewall = true;
    allowSFTP = false;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      challengeResponseAuthentication = false;
      X11Forwarding = false;
      KbdInteractiveAuthentication = false;
      UsePAM = true;
    };
    extraConfig = ''
      AllowTcpForwarding yes
      AllowAgentForwarding yes
      AllowStreamLocalForwarding no
      AuthenticationMethods publickey
    '';
  };

  security.pam.sshAgentAuth = {
    enable = true;
    authorizedKeysFiles = [ "/etc/ssh/authorized_keys.d/%u" ];
  };

  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "24h";
  };
}
