{...}: {
  kubix.manifests.longhorn-system-namespace = {
    apiVersion = "v1";
    kind = "Namespace";
    metadata = {
      name = "longhorn-system";
    };
  };

  kubix.helmCharts.longhorn = {
    repo = "https://charts.longhorn.io";
    chartName = "longhorn";
    chartVersion = "v1.9.1";
    hash = "sha256-jDI7vHl0QNAgFEgAdPf8HoG7OcnRED3QNMSN+tFoxaI=";
    namespace = "longhorn-system";
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

  kubix.manifests.longhorn-default-backups = {
    apiVersion = "longhorn.io/v1beta2";
    kind = "RecurringJob";
    metadata.name = "default-backups";
    spec = {
      cron = "0 4 * * *";
      task = "backup";
      groups = ["default"];
      retain = "3";
      concurrency = "2";
    };
  };

  kubix.manifests.longhorn-backblaze-creds = {
    apiVersion = "v1";
    kind = "Secret";
    metadata.name = "backblaze-creds";
    type = "Opaque";
    data = {
      AWS_ENDPOINTS = "aHR0cHM6Ly9zMy51cy13ZXN0LTAwMi5iYWNrYmxhemViMi5jb206NDQz"; # https://s3.us-west-002.backblazeb2.com:443
      AWS_ACCESS_KEY_ID = "MDAyMTUwNDUwZTc1MDMzMDAwMDAwMDAwNQ=="; # 002150450e750330000000005
      AWS_SECRET_ACCESS_KEY = "SzAwMmlUeVVKZUpyMkR1bjRNOHhIa1ZBWnJ2VG5Zaw=="; # TODO: use sops-nix
    };
  };
}
