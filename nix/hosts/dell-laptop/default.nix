# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  networking.hostName = "dell-laptop"; # Define your hostname.

  nixpkgs.config.allowUnfree = true;

  my.profiles.workstation.enable = true;

  catppuccin.sddm.background = ../../../wallpapers/login_wallpaper_3840x2160.png;

  system.stateVersion = "24.11"; # Did you read the comment?
}
