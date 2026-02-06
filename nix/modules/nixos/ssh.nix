{
  lib,
  config,
  ...
}: let
  cfg = config.my.services.ssh;
  imp = config.my.system.impermanence;
in {
  options.my.services.ssh = {
    enable = lib.mkEnableOption "Enable SSH server services";
  };

  config = lib.mkMerge [
    ##########
    ## MAIN SSH CONFIG
    ##########
    (lib.mkIf cfg.enable {
      services.openssh = {
        enable = true;
        allowSFTP = false;
        ports = [22];
        openFirewall = false;

        hostKeys = [
          {
            path = "/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
          {
            path = "/etc/ssh/ssh_host_rsa_key";
            type = "rsa";
            bits = "4096";
          }
        ];

        # https://infosec.mozilla.org/guidelines/openssh#modern-openssh-67
        settings = {
          LogLevel = "VERBOSE";
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = true;

          KexAlgorithms = [
            "curve25519-sha256@libssh.org"
            "ecdh-sha2-nistp521"
            "ecdh-sha2-nistp384"
            "ecdh-sha2-nistp256"
            "diffie-hellman-group-exchange-sha256"
          ];
          Ciphers = [
            "chacha20-poly1305@openssh.com"
            "aes256-gcm@openssh.com"
            "aes128-gcm@openssh.com"
            "aes256-ctr"
            "aes192-ctr"
            "aes128-ctr"
          ];
          Macs = [
            "hmac-sha2-512-etm@openssh.com"
            "hmac-sha2-256-etm@openssh.com"
            "umac-128-etm@openssh.com"
            "hmac-sha2-512"
            "hmac-sha2-256"
            "umac-128@openssh.com"
          ];
        };

        extraConfig = ''
          ClientAliveCountMax 0
          ClientAliveInterval 300

          AllowTcpForwarding no
          AllowAgentForwarding no
          MaxAuthTries 3
          MaxSessions 2
          TCPKeepAlive no
        '';
      };

      networking.firewall.extraCommands = ''
        # limit ssh traffic to local network
        iptables -I INPUT -s 192.168.0.0/16 -m state --state NEW -p tcp --dport 22 -j ACCEPT
      '';

      services.fail2ban = {
        enable = true;
        maxretry = 10;
        bantime-increment.enable = true;
      };

      # CLI tools to debug with
      environment.systemPackages = [
        config.services.openssh.package
      ];
    })

    ##########
    ## IMPERMANENCE INTEGRATION
    ##########
    (lib.mkIf (cfg.enable && imp.enable) {
      environment.persistence."${imp.persistPath}" = {
        files = [
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
        ];
      };
    })
  ];
}
