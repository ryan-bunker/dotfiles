{
  inputs,
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

  nix = {
    channel.enable = false;
    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "@wheel"];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "delete-older-than 7d";
      persistent = false;
    };

    optimise = {
      automatic = true;
      dates = ["weekly"];
    };
  };

  my.users.ryan.enable = true;

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
