{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.my.users.ryan;
in {
  options.my.users.ryan = {
    enable = lib.mkEnableOption "Add the user ryan to the system";
  };

  config = lib.mkIf cfg.enable {
    users.users.ryan = {
      isNormalUser = true;
      home = "/home/ryan";
      uid = 1000;
      extraGroups = ["wheel" "networkmanager" "video"];
      shell = pkgs.zsh;
      hashedPasswordFile = config.sops.secrets."passwords/ryan".path;
      openssh.authorizedKeys.keys = [
        lib.fileContents
        ../../../../secrets/keys/desktop/public
        lib.fileContents
        ../../../../secrets/keys/laptop/public
      ];
    };

    sops.secrets."passwords/ryan" = {
      sopsFile = ../../../../secrets/passwords.yaml;
      # Ensure that the secret is available when creating users
      neededForUsers = true;
    };

    # Ensure ZSH is enabled at the system level for login
    programs.zsh.enable = true;
  };
}
