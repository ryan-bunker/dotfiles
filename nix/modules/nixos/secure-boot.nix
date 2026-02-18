{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.system.secure-boot;
  imp = config.my.system.impermanence;
in {
  options = {
    my.system.secure-boot.enable = lib.mkEnableOption "Enables secure boot";
  };

  config = lib.mkIf cfg.enable {
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    environment.persistence = lib.mkIf imp.enable {
      "${imp.persistPath}" = {
        directories = ["/var/lib/sbctl"];
      };
    };

    # Disable systemd-boot because lanzaboote installs the signed bootloader
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.initrd.systemd.enable = true;
    boot.initrd.systemd.tpm2.enable = true;

    security.tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };

    # CLI tools to debug with
    environment.systemPackages = with pkgs; [
      sbctl
      tpm2-tools
    ];
  };
}
