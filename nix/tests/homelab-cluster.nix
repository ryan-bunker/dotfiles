{
  pkgs,
  self,
  ...
}:
pkgs.testers.nixosTest {
  name = "homelab-cluster-test";

  nodes = {
    kube-1 = {config, ...}: {
      imports = [self.nixosModules.default ../hosts/kube/kube-1.nix];
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
