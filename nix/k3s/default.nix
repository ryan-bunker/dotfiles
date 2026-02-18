{
  lib,
  pkgs,
  config,
  kubenix,
  inputs,
  ...
}: {
  imports = [
    ./longhorn.nix
    ./metallb.nix
  ];

  # # # Configure kubenix to output a single yaml file
  # # kubernetes.outputYAML = true;
  # kubernetes.resources.namespaces.metallb-system = {
  #   apiVersion = "v1";
  #   kind = "Namespace";
  #   metadata = {
  #     name = "metallb-system";
  #   };
  # };

  # kubernetes.helm.releases = {
  #   metallb = {
  #     chart = kubenix.lib.helm.fetch {
  #       repo = "https://metallb.github.io/metallb";
  #       chart = "metallb";
  #       version = "0.14.8";
  #       sha256 = "sha256-CHf0YnutvnItwZtFf3+3mhcfRDoSADl/6ovDoRHqwLM=";
  #     };
  #     namespace = "metallb-system";
  #   };
  #   longhorn = {
  #     chart = kubenix.lib.helm.fetch {
  #       repo = "https://charts.longhorn.io";
  #       chart = "longhorn";
  #       version = "1.9.1";
  #       sha256 = "sha256-jDI7vHl0QNAgFEgAdPf8HoG7OcnRED3QNMSN+tFoxaI=";
  #     };
  #     namespace = "longhorn-system";

  #     values = {
  #       defaultBackupStore = {
  #         backupTarget = "s3://bunker-house-backups@dummyregion/dev/longhorn-backups";
  #         backupTargetCredentialSecret = "backblaze-creds";
  #       };
  #       ingress = {
  #         enabled = true;
  #         host = "longhorn.dev.thebunker.house";
  #         annotations = {
  #           "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure";
  #           "traefik.ingress.kubernetes.io/router.middlewares" = "traefik-system-traefik-dashboard-auth@kubernetescrd";
  #         };
  #       };
  #     };
  #   };
  # };

  # kubernetes.resources.services.metallb-webhook-service = {
  #   spec.ports = lib.mkForce [
  #     {
  #       port = 443;
  #       targetPort = 9443;
  #       protocol = "TCP";
  #     }
  #   ];
  # };

  # kubix.manifests.example-configmap = {
  #   apiVersion = "v1";
  #   kind = "ConfigMap";
  #   metadata = {
  #     name = "example-configmap";
  #     namespace = "default";
  #   };
  #   data = {
  #     "cool-data" = "foo";
  #   };
  # };
}
