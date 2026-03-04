{
  lib,
  config,
  charts,
  ...
}: let
  cfg = config.my.k3s.cert-manager;
in {
  options.my.k3s.cert-manager = {};

  config.applications.cert-manager = {
    namespace = "cert-manager-system";
    createNamespace = true;

    helm.releases.cert-manager = {
      chart = charts.jetstack.cert-manager;
      values = {
        crds.enabled = true;
        dns01RecursiveNameservers = "1.1.1.1:53";
        dns01RecursiveNameserversOnly = true;
      };
    };
  };
}
