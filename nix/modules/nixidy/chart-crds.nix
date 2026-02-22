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
    longhorn = {
      chart = charts.longhorn.longhorn;
      crds = ["RecurringJob"];
    };
    metallb = {
      chart = charts.metallb.metallb;
      crds = ["IPAddressPool" "L2Advertisement"];
    };
  };
in {
  nixidy.applicationImports = lib.attrsets.mapAttrsToList mkCRDs genCharts;
}
