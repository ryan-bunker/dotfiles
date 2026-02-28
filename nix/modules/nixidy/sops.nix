{
  lib,
  config,
  charts,
  ...
}: let
  cfg = config.my.k3s.sops;
in {
  options.my.k3s.sops = {};

  config.applications.sops-secrets-operator = {
    namespace = "sops-system";
    # because we have to manually inject the age key into the environment
    # the namespace has to already exist, meaning it has to be manually
    # created as well
    createNamespace = false;

    helm.releases.sops-secrets-operator = {
      chart = charts.isindir.sops-secrets-operator;
      values = {
        secretsAsFiles = [
          {
            mountPath = "/etc/sops-age-key-file";
            name = "sops-age-key-file";
            secretName = "sops-age";
          }
        ];
        extraEnv = [
          {
            name = "SOPS_AGE_KEY_FILE";
            value = "/etc/sops-age-key-file/keys.txt";
          }
        ];
      };
    };
  };
}

