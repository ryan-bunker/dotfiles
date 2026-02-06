{
  lib,
  config,
  ...
}: let
  cfg = config.my.storage;
in {
  options.my.storage = {
    enable = lib.mkEnableOption "Custom btrfs disko layout";

    mainDisk = lib.mkOption {
      type = lib.types.str;
      default = "/dev/sda";
      description = "The primary disk for OS and boot";
    };
    dataDisks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Optional list of additional data disks";
    };
  };

  config = lib.mkIf cfg.enable {
    disko.devices = {
      disk =
        {
          main = {
            type = "disk";
            device = cfg.mainDisk;
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  priority = 1;
                  name = "ESP";
                  start = "1M";
                  end = "512M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                  };
                };
                root = {
                  size = "100%";
                  content = {
                    type = "btrfs";
                    extraArgs = ["--force" "-L" "NIXOS"];

                    # Subvolumes must set a mountpoint in order to
                    # be mounted unless their parent is mounted
                    subvolumes = {
                      "/root" = {
                        mountpoint = "/";
                        mountOptions = ["compress=zstd"];
                      };
                      "/home" = {
                        mountpoint = "/home";
                        mountOptions = ["compress=zstd"];
                      };
                      "/nix" = {
                        mountpoint = "/nix";
                        mountOptions = ["compress=zstd" "noatime"];
                      };
                      "/persist" = {
                        mountpoint = "/persist";
                        mountOptions = ["compress=zstd" "noatime"];
                      };
                    };
                  };
                };
              };
            };
          };
        }
        // lib.optionalAttrs (cfg.dataDisks != []) {
          data = {
            type = "disk";
            device = lib.lists.head cfg.dataDisks;
            content = {
              type = "btrfs";
              extraArgs =
                [
                  "--force"
                  "--data"
                  "single"
                  "--metadata"
                  "single"
                ]
                ++ builtins.tail cfg.dataDisks;

              # Subvolumes must set a mountpoint in order to be mounted,
              # unless their parent is mounted
              subvolumes = {
                "/data" = {
                  mountOptions = ["compress=zstd" "noatime"];
                  mountpoint = "/data";
                };
              };
            };
          };
        };
    };
  };
}
