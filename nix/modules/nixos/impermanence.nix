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
    boot.initrd = {
      supportedFilesystems = ["btrfs"];
      systemd.enable = true;
      # the rollback script - this resets the root drive on boot, putting the old
      # data in a temporary directory for safety
      systemd.services.btrfs-rollback = {
        description = "Rollback btrfs root to blank snapshot";
        wantedBy = ["initrd.target"];

        # Wait for the specific device unit
        # "/dev/disk/by-label/NIXOS" translates to "dev-disk-by\x2dlabel-NIXOS.device"
        # (\x2d is the escaped hyphen for 'by-label')
        requires = ["dev-disk-by\\x2dlabel-NIXOS.device"];
        after = ["dev-disk-by\\x2dlabel-NIXOS.device"];

        before = ["sysroot.mount"];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          echo "Rolling back btrfs root to blank snapshot..."
          mkdir /btrfs_tmp
          mount -t btrfs /dev/disk/by-label/NIXOS /btrfs_tmp

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

    # Explicitly tell NixOS that this mount is required for the system to come up.
    fileSystems."${cfg.persistPath}".neededForBoot = true;
  };
}
