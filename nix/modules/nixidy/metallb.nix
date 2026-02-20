{
  lib,
  config,
  charts,
  ...
}: let
  cfg = config.my.k3s.metallb;
in {
  options.my.k3s.metallb = {};

  config.applications.metallb = {
    namespace = "metallb-system";
    createNamespace = true;

    helm.releases.metallb = {
      chart = charts.metallb.metallb;
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
}
