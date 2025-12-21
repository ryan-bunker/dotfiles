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
      type = types.str;
      default = "ssh_key";
      description = "Name of key in sops secrets file that contains private SSH key";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";

      matchBlocks."*".identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
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
    home.file.".ssh/id_ed25519.pub".text = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtZ8rdN4bP15DEbGFaL5K0lq9jQus0Ya/WMiZLg38v4 ryan.bunker@gmail.com
    '';
  };
}
