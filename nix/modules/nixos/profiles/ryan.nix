{
  pkgs,
  config,
  ...
}: {
  users.users.ryan = {
    isNormalUser = true;
    uid = 1000; # Ensure consistent UID across all Bunker nodes
    extraGroups = ["wheel" "networkmanager" "video"];
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets.my_password.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtZ8rdN4bP15DEbGFaL5K0lq9jQus0Ya/WMiZLg38v4 ryan.bunker@gmail.com"
    ];
  };

  # Ensure that the my_password secret is available when creating users
  sops.secrets.my_password.neededForUsers = true;

  # Ensure ZSH is enabled at the system level for login
  programs.zsh.enable = true;
}
