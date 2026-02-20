{
  lib,
  config,
  charts,
  ...
}: let
  cfg = config.my.k3s.longhorn;
in {
  options.my.k3s.longhorn = {};

  config.applications.longhorn = {
    namespace = "longhorn-system";
    createNamespace = true;

    helm.releases.metallb = {
      chart = charts.longhorn.longhorn;
      values = {
        defaultBackupStore = {
          backupTarget = "s3://bunker-house-backups@dummyregion/dev/longhorn-backups";
          backupTargetCredentialSecret = "backblaze-creds";
        };
        ingress = {
          enabled = "true";
          host = "longhorn.dev.thebunker.house";
          annotations = {
            "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure";
            "traefik.ingress.kubernetes.io/router.middlewares" = "traefik-system-traefik-dashboard-auth@kubernetescrd";
          };
        };
      };
    };

    resources."longhorn.io"."v1beta2" = {
      RecurringJob."default-backups".spec = {
        cron = "0 4 * * *";
        task = "backup";
        groups = ["default"];
        retain = 3;
        concurrency = 2;
      };
    };

    resources.secrets.backblaze-creds = {
      type = "Opaque";
      data = {
        AWS_ENDPOINTS = "aHR0cHM6Ly9zMy51cy13ZXN0LTAwMi5iYWNrYmxhemViMi5jb206NDQz"; # https://s3.us-west-002.backblazeb2.com:443
        AWS_ACCESS_KEY_ID = "MDAyMTUwNDUwZTc1MDMzMDAwMDAwMDAwNQ=="; # 002150450e750330000000005
        AWS_SECRET_ACCESS_KEY = "SzAwMmlUeVVKZUpyMkR1bjRNOHhIa1ZBWnJ2VG5Zaw=="; # TODO: use sops-nix
      };
    };
  };
}
