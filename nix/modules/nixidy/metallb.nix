{
  lib,
  config,
  ...
}: let
  cfg = config.my.k3s.metallb;
in {
  options.my.k3s.metallb = {};

  config.applications.metallb = {
    namespace = "metallb-system";
    createNamespace = true;

    helm.releases.metallb = {
      chart = lib.helm.downloadHelmChart {
        repo = "https://metallb.github.io/metallb";
        chart = "metallb";
        version = "0.14.8";
        chartHash = "sha256-CHf0YnutvnItwZtFf3+3mhcfRDoSADl/6ovDoRHqwLM=";
      };
    };

    resources."metallb.io"."v1beta1" = {
      IPAddressPool."default-pool" = {
        spec.addresses = ["192.168.122.192/26"];
      };

      L2Advertisement."default-pool" = {
        spec.ipAddressPools = ["default-pool"];
      };
    };
  };

  # config.kubernetes.resources.ipaddresspools."default-pool" = {
  #   metadata = {
  #     namespace = "metallb-system";
  #     labels = {
  #       managed-by = "nixidy";
  #     };
  #   };
  #   spec.addresses = [
  #     "192.168.1.200-192.168.1.250" # Your McKinney home network range
  #   ];
  # };
}
