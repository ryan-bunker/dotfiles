{
  lib,
  pkgs,
  config,
  ...
}: {
  users.users.ryan = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = ["wheel" "networkmanager" "video"];
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets.my_password.path;
    openssh.authorizedKeys.keys = [
      lib.fileContents
      ../../../../secrets/keys/desktop/public
      lib.fileContents
      ../../../../secrets/keys/laptop/public
    ];
  };

  # Ensure that the my_password secret is available when creating users
  sops.secrets.my_password.neededForUsers = true;

  # Ensure ZSH is enabled at the system level for login
  programs.zsh.enable = true;
}
