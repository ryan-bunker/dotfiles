{
  pkgs,
  self,
  ...
}: let
  testPrivateKey = ''
    -----BEGIN OPENSSH PRIVATE KEY-----
    b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
    QyNTUxOQAAACCOJLp6v8tizFtNLVPGombvxKtpeKLcbX7wTZNK1eF+jQAAAJjoK7n66Cu5
    +gAAAAtzc2gtZWQyNTUxOQAAACCOJLp6v8tizFtNLVPGombvxKtpeKLcbX7wTZNK1eF+jQ
    AAAEAXHQEo6J1/Ybca52ge1EduvHyFEYeAJ5UWbgv/yErbo44kunq/y2LMW00tU8aiZu/E
    q2l4otxtfvBNk0rV4X6NAAAAFXJ5YW4uYnVua2VyQGdtYWlsLmNvbQ==
    -----END OPENSSH PRIVATE KEY-----
  '';
  testPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4kunq/y2LMW00tU8aiZu/Eq2l4otxtfvBNk0rV4X6N ryan.bunker@gmail.com";

  mkKube = name: {
    config,
    lib,
    ...
  }: {
    imports = self.nixosConfigurations.${name}._module.args.modules;
    users.users.ryan = {
      hashedPasswordFile = lib.mkForce "";
      openssh.authorizedKeys.keys = lib.mkForce [testPublicKey];
    };
    virtualisation.memorySize = 4096;
  };
in
  pkgs.testers.nixosTest {
    name = "homelab-cluster-test";

    nodes = {
      bastion = {pkgs, ...}: {
        environment.systemPackages = [pkgs.openssh];
        systemd.tmpfiles.rules = [
          # Type  Path                    Mode User Group Age Argument
          "d      /root/.ssh              0700 root root  -   -"
          "C      /root/.ssh/id_ed25519   0600 root root  -   ${pkgs.writeText "test-key" testPrivateKey}"
        ];
      };

      kube-1 = mkKube "kube-1";
      kube-2 = mkKube "kube-2";
      kube-3 = mkKube "kube-3";
    };

    testScript = ''
      start_all()

      # Ensure bastion is ready
      bastion.wait_for_unit("network.target")

      def check_ssh(node, ip_address):
        node.wait_for_unit("multi-user.target")

        # Check that the unit has finished and the result was 'success'
        # This command returns 0 if the service finished successfully, even if it's now inactive.
        node.wait_until_succeeds(
            "systemctl show home-manager-ryan.service --property=Result | grep -q 'Result=success'"
        )

        node.wait_for_unit("sshd.service")

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
