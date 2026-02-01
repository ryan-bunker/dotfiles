{
  lib,
  config,
  pkgs,
  ...
}: {
  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  time.timeZone = "US/Central";

  # Allow installing unfree packages.
  # nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };

  # TODO: move this to a separate module
  sops.secrets.my_password.neededForUsers = true;
  users.users.ryan = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel" # Enable ‘sudo’ for the user.
    ];
    hashedPasswordFile = config.sops.secrets.my_password.path;
  };

  # setup zsh as the default system shell - enabling it here is required so it functions properly
  # full configuration happens as part of home-manager
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };
  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = with pkgs; [
    btrfs-progs
    git
    vim
    wget
  ];
}
