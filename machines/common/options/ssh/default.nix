{ config, ... }:
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

  security.pam.services.sshd.rules.session.env-pre-systemd = {
    order = config.security.pam.services.sshd.rules.session.systemd.order - 1;
    enable = true;
    control = "optional";
    modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
    args = [
      "log=/var/log/gotify-ssh.log"
      "/etc/notify.sh"
    ];
  };
}
