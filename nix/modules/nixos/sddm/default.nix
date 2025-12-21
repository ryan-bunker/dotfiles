{
  lib,
  config,
  ...
}: let
  cfg = config.my.desktop.sddm;
in {
  options.my.desktop.sddm = {
    enable = lib.mkEnableOption "Enable SDDM display manager";
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      enableHidpi = true;
    };
  };
}
