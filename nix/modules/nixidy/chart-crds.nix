{
  lib,
  charts,
  generators,
  ...
}: let
  mkCRDs = name: {
    chart,
    crds,
  }: "${generators.fromChartCRD {
    inherit name chart crds;
  }}";

  genCharts = {
    sops = {
      chart = charts.isindir.sops-secrets-operator;
      crds = ["SopsSecret"];
    };
    longhorn = {
      chart = charts.longhorn.longhorn;
      crds = ["RecurringJob"];
    };
    metallb = {
      chart = charts.metallb.metallb;
      crds = ["IPAddressPool" "L2Advertisement"];
    };
    cert-manager = {
      chart = charts.jetstack.cert-manager;
      crds = ["Issuer" "Certificate"];
    };
    traefik = {
      chart = charts.traefik.traefik;
      crds = ["Middleware"];
    };
  };
in {
  nixidy.applicationImports = lib.attrsets.mapAttrsToList mkCRDs genCharts;
}
