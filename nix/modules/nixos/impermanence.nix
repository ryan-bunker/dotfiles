{
  lib,
  config,
  ...
}: let
  cfg = config.my.system.impermanence;
in {
  options.my.system.impermanence = {
    enable = lib.mkEnableOption "Enable ephemeral root with btrfs rollback";

    persistPath = lib.mkOption {
      type = lib.types.str;
      default = "/persist";
      description = "The mount point of your persistent btrfs subvolume";
    };
  };

  config = lib.mkIf cfg.enable {
    # the rollback script - this resets the root drive on boot, putting the old
    # data in a temporary directory for safety
    boot.initrd.systemd.services.btrfs-rollback = {
      description = "Rollback btrfs root to blank snapshot";
      wantedBy = ["initrd.target"];
      after = ["systemd-cryptsetup@enc.service"];
      before = ["sysroot.mount"];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir /btrfs_tmp
        mount /dev/disk/by-label/NIXOS /btrfs_tmp

        if [[ -e /btrfs_tmp/root ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
          mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
        fi

        delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
          done
          btrfs subvolume delete "$1"
        }

        for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
          delete_subvolume_recursively "$i"
        done

        btrfs subvolume create /btrfs_tmp/root
        umount /btrfs_tmp
      '';
    };

    # essential system paths that MUST persist for the machine to boot
    environment.persistence."${cfg.persistPath}" = {
      enable = true;
      directories = [
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };
}
