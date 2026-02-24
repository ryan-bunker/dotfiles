{
  lib,
  config,
  charts,
  ...
}: let
  cfg = config.my.k3s.metallb;
in {
  options.my.k3s.metallb = {
    addresses = lib.mkOption {
      type = lib.types.str;
      description = "Network space for metallb addresses in CIDR form.";
    };
  };

  config.applications.metallb = {
    namespace = "metallb-system";
    createNamespace = true;

    helm.releases.metallb = {
      chart = charts.metallb.metallb;
    };

    resources."metallb.io"."v1beta1" = {
      IPAddressPool."default-pool" = {
        spec.addresses = [cfg.addresses];
      };

      L2Advertisement."default-pool" = {
        spec.ipAddressPools = ["default-pool"];
      };
    };
  };
}
