{envCfg, ...}: {
  nixidy.target = {
    repository = "https://github.com/ryan-bunker/dotfiles.git";
    branch = "ryan-home";
    rootPath = "./nix/k3s/manifests/dev";
  };

  my.k3s.metallb.addresses = envCfg.network.metallb_range;

  my.k3s.longhorn.baseDomain = envCfg.domain;

  my.k3s.pihole = {
    domain = envCfg.domain;
    ip = envCfg.network.pihole_ip;
    reverseCidr = "${envCfg.network.prefix}/${toString envCfg.network.prefixLength}";
    reverseTarget = envCfg.network.gateway;
  };

  my.k3s.csi-driver-nfs = {
    server = envCfg.nas.ip;
    share = "/k8s-volumes";
  };

  my.k3s.traefik = {
    ip = envCfg.network.traefik_ip;
    baseDomain = envCfg.domain;
  };

  # # Define the nginx application
  # applications.nginx = {
  #   # Deploy to the "nginx" namespace
  #   namespace = "nginx";

  #   # Automatically create the namespace
  #   createNamespace = true;

  #   # Define Kubernetes resources
  #   resources = {
  #     # Deployment
  #     deployments.nginx.spec = {
  #       replicas = 2;
  #       selector.matchLabels.app = "nginx";
  #       template = {
  #         metadata.labels.app = "nginx";
  #         spec.containers.nginx = {
  #           image = "nginx:1.25.1";
  #           ports.http.containerPort = 80;
  #         };
  #       };
  #     };

  #     # Service
  #     services.nginx.spec = {
  #       selector.app = "nginx";
  #       ports.http.port = 80;
  #     };
  #   };
  # };
}
