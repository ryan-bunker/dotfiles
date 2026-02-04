{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.programs.ssh;
in {
  options.my.programs.ssh = {
    enable = lib.mkEnableOption "Enable and configure ssh (client)";

    publicKeyFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the public key file (e.g. ./keys/desktop.pub)";
    };

    privateKey = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = ''
        Configuration for the private key secret.
        Example: { sopsFile = ./private; format = "binary"; }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks."*" = {
        identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
        # Auto-add key to agent on first use.
        addKeysToAgent = "yes";
        # Keep Alive - Send a "ping" to the server every 60 seconds. If the
        # server misses 3 pings, disconnect cleanly.
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };
    };

    # install private key - take the user's definition and force the destination path
    sops.secrets.ssh_key =
      cfg.privateKey
      // {
        # Explicitly tell sops-nix where to place the decrypted file
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };

    # install the public key
    home.file.".ssh/id_ed25519.pub".source = cfg.publicKeyFile;
  };
}
