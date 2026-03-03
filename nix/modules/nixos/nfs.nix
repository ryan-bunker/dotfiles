{
  lib,
  config,
  ...
}: let
  cfg = config.my.services.nfs;
in {
  options.my.services.nfs = {
    enable = lib.mkEnableOption "Enables NFS";

    exports = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({share, ...}: {
        options = {
          share = lib.mkOption {
            type = lib.types.str;
            example = "k8s-volumes";
            description = "Name of the share to expose.";
          };

          client = lib.mkOption {
            type = lib.types.str;
            example = "192.168.1.0/24";
            description = "Client access for share.";
          };

          options = lib.mkOption {
            type = lib.types.str;
            default = "rw,no_root_squash";
            description = "Share options.";
          };

          data_path = lib.mkOption {
            type = lib.types.str;
            default = "/data";
            description = "The base path on the disk where the shared data is stored.";
          };
        };
      }));
    };
  };

  config = lib.mkIf cfg.enable {
    services.nfs.server = {
      enable = true;

      exports = lib.strings.concatLines (
        ["/export *(ro,fsid=0,root_squash,subtree_check)"]
        ++ lib.attrsets.mapAttrsToList (name: value: "/export/${name} ${value.client}(${value.options})") cfg.exports
      );
    };

    services.nfs.settings = {
      nfsd.udp = false;
      nfsd.vers3 = false;
      nfsd.vers4 = true;
      nfsd."vers4.0" = false;
      nfsd."vers4.1" = false;
      nfsd."vers4.2" = true;
    };

    systemd.tmpfiles.rules =
      [
        "d /export 0755 nobody nogroup"
      ]
      ++ (lib.attrsets.mapAttrsToList (name: value: "d ${value.data_path}/${name} 0777 root root") cfg.exports);

    fileSystems = lib.attrsets.mapAttrs' (name: value:
      lib.attrsets.nameValuePair "/export/${name}" {
        device = "${value.data_path}/${name}";
        options = ["bind"];
      })
    cfg.exports;

    networking.firewall.allowedTCPPorts = [2049];
  };
}
