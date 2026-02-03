{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.profiles.server;
in {
  options = {
    my.profiles.server.enable = lib.mkEnableOption "Server Machine Profile";
  };

  config = lib.mkIf cfg.enable {
    my.storage.enable = true;
    my.services.ssh.enable = true;

    boot.supportedFilesystems = ["nfs"];

    environment.systemPackages = with pkgs; [
      vim
    ];
  };
}
