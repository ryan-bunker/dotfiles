{
  pkgs,
  self,
  ...
}:
pkgs.testers.nixosTest {
  name = "homelab-cluster-test";

  nodes = {
    kube-1 = {config, ...}: {
      imports = self.nixosConfigurations.kube-1._module.args.modules;

      virtualisation.memorySize = 4096;
      virtualisation.sharedDirectories.sops-age-key = {
        source = "/home/ryan/.config/sops/age";
        target = "/var/lib/sops-nix";
      };
    };
  };

  testScript = ''
    start_all()
  '';
}
