{
  lib,
  config,
  charts,
  ...
}: let
  cfg = config.my.k3s.csi-driver-nfs;
in {
  options.my.k3s.csi-driver-nfs = {
    server = lib.mkOption {
      type = lib.types.str;
      description = "The IP or hostname of the NFS server";
    };
    share = lib.mkOption {
      type = lib.types.str;
      description = "Path of the exported share on the NFS server";
    };
  };

  config.applications.csi-driver-nfs = {
    namespace = "kube-system";
    createNamespace = false;

    helm.releases.csi-driver-nfs = {
      # TODO: nixhelm chart currently has a bad chartHash that causes errors
      # chart = charts.kubernetes-csi.csi-driver-nfs;
      chart = lib.helm.downloadHelmChart {
        repo = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts";
        chart = "csi-driver-nfs";
        version = "4.13.1";
        chartHash = "sha256-mH62iC0pqxy+lYgeyGSEEstoEXk1CJ/i83hQzZw0284=";
      };
      values = {
        externalSnapshotter.enabled = true;
        controller.runOnControlPlane = true;
        controller.replicas = 2;

        storageClass.create = true;
        storageClasses = [
          {
            name = "nfs-retain";
            parameters = {inherit (cfg) server share;};
            reclaimPolicy = "Retain";
            volumeBindingMode = "Immediate";
            mountOptions = ["nfsvers=4.2"];
          }
        ];
      };
    };
  };
}
