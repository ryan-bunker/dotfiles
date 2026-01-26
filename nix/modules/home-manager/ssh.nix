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

    sopsKey = lib.mkOption {
      type = lib.types.str;
      default = "ssh_key";
      description = "Name of key in sops secrets file that contains private SSH key";
    };

    publicKey = lib.mkOption {
      type = lib.types.str;
      description = "Public key contents to write to ssh configuration";
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

    # 1. THE PRIVATE KEY (Secret)
    sops.secrets.ssh_key = {
      key = cfg.sopsKey;
      # Explicitly tell sops-nix where to place the decrypted file
      path = "${config.home.homeDirectory}/.ssh/id_ed25519";
      mode = "0600";
    };

    # 2. THE PUBLIC KEY (Not Secret)
    # Since this isn't sensitive, just write it as a standard file.
    # This ensures 'ssh-copy-id' or other tools can find the .pub file.
    home.file.".ssh/id_ed25519.pub".text = cfg.publicKey;
  };
}
