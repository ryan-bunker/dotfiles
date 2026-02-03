{
  pkgs,
  self,
  ...
}: let
  mkKube = name: {config, ...}: {
    imports = self.nixosConfigurations.${name}._module.args.modules;
    virtualisation.memorySize = 4096;
    virtualisation.sharedDirectories.sops-age-key = {
      source = "/home/ryan/.config/sops/age";
      target = "/var/lib/sops-nix";
    };
  };
in
  pkgs.testers.nixosTest {
    name = "homelab-cluster-test";

    nodes = {
      bastion = {...}: {
        environment.systemPackages = [pkgs.openssh];
      };

      kube-1 = mkKube "kube-1";
      kube-2 = mkKube "kube-2";
      kube-3 = mkKube "kube-3";
    };

    testScript = ''
      start_all()

      # Ensure bastion is ready
      bastion.wait_for_unit("network.target")

      # 1. Generate a key on the bastion
      bastion.succeed("mkdir -p ~/.ssh && ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N '''")
      public_key = bastion.succeed("cat ~/.ssh/id_ed25519.pub")

      def check_ssh(node, ip_address):
        node.wait_for_unit("multi-user.target")

        # Check that the unit has finished and the result was 'success'
        # This command returns 0 if the service finished successfully, even if it's now inactive.
        node.wait_until_succeeds(
            "systemctl show home-manager-ryan.service --property=Result | grep -q 'Result=success'"
        )

        node.wait_for_unit("sshd.service")

        # 2. Put the public key on the node (simulating deployment)
        node.succeed("mkdir -p /home/ryan/.ssh && chmod 700 /home/ryan/.ssh")
        node.succeed(f"echo '{public_key}' > /home/ryan/.ssh/authorized_keys")
        node.succeed("chown -R ryan:users /home/ryan/.ssh && chmod 600 /home/ryan/.ssh/authorized_keys")

        # 3. Test the connection from bastion to the node's static IP
        hostname = node.succeed("hostname").strip()
        bastion.succeed(f"ssh -o StrictHostKeyChecking=no ryan@{ip_address} 'hostname' | grep {hostname}")

      # wait for servers to be ready
      check_ssh(kube_1, "192.168.1.100")
      check_ssh(kube_2, "192.168.1.101")
      check_ssh(kube_3, "192.168.1.102")

      bastion.log("SSH verification successful!")
    '';

    interactive.nodes = {
      bastion.virtualisation.graphics = false;
      kube-1.virtualisation.graphics = false;
      kube-2.virtualisation.graphics = false;
      kube-3.virtualisation.graphics = false;
    };
  }
