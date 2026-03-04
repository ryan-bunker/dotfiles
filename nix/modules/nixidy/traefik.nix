{
  lib,
  config,
  charts,
  ...
}: let
  cfg = config.my.k3s.traefik;
in {
  options.my.k3s.traefik = {
    baseDomain = lib.mkOption {
      type = lib.types.str;
      description = "Base domain of environment";
    };
    ip = lib.mkOption {
      type = lib.types.str;
      description = "Static IP address to request from MetalLB for the Traefik LoadBalancer";
    };
  };

  config.applications.traefik = {
    namespace = "traefik-system";
    createNamespace = true;

    helm.releases.traefik = {
      chart = charts.traefik.traefik;
      values = {
        service = {
          spec = {
            loadBalancerIP = cfg.ip;
          };
        };
        ingressRoute.dashboard = {
          enabled = true;
          matchRule = "Host(`traefik.${cfg.baseDomain}`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))";
          entryPoints = ["websecure"];
          middlewares = [{name = "traefik-dashboard-auth";}];
        };

        # ports.web.redirections.entryPoint = {
        #   to = "websecure";
        #   scheme = "https";
        #   permanent = true;
        # };

        # tlsStore.default.defaultCertificate.secretName = "wildcard-root-domain-tls";

        # logs = {
        #   general.level = "DEBUG";
        #   access.enabled = true;
        #   access.format = "json";
        # };

        # providers.kubernetesCRD.allowExternalNameServices = true;
      };
    };

    resources.secrets.traefik-dashboard-auth-secret = {
      type = "kubernetes.io/basic-auth";
      stringData = {
        username = "admin";
        password = "changeme";
      };
    };

    resources."traefik.io"."v1alpha1".Middleware.traefik-dashboard-auth = {
      spec.basicAuth.secret = "traefik-dashboard-auth-secret";
    };
  };
}
