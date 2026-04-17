{
  description = "Home Manager configuration of I845798";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alejandra = {
      url = "github:kamadorueda/alejandra/4.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixidy = {
      url = "github:arnarg/nixidy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixhelm = {
      url = "github:farcaller/nixhelm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    # Import the central data file for environments and nodes
    environments = import ./environments.nix;

    # helper to import tests and pass the flake's self/inputs
    mkTest = file:
      import file {
        inherit self;
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
      };
  in {
    nixosModules = {
      default = {...}: {
        imports = [
          inputs.catppuccin.nixosModules.catppuccin
          inputs.disko.nixosModules.disko
          inputs.impermanence.nixosModules.impermanence
          inputs.lanzaboote.nixosModules.lanzaboote
          inputs.sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          ./modules/nixos
        ];
        _module.args = inputs // {inherit inputs;};
      };
    };

    homeManagerModules = {
      default = {...}: {
        imports = [
          inputs.ags.homeManagerModules.default
          inputs.catppuccin.homeModules.catppuccin
          inputs.sops-nix.homeManagerModules.sops
          inputs.spicetify-nix.homeManagerModules.spicetify
          ./modules/home-manager
        ];
        _module.args = inputs // {inherit inputs;};
      };
    };

    nixosConfigurations = let
      # Generic helper to build a single Kubernetes node configuration
      mkKubeNode = {
        hostName,
        envCfg,
        nodeCfg,
      }:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {inherit envCfg nodeCfg;};
          modules = [
            self.nixosModules.default
            ./hosts/kube
            {
              networking.hostName = hostName;

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        };

      mkEnv = envCfg:
        inputs.nixpkgs.lib.mapAttrs (name: node:
          mkKubeNode {
            hostName = name;
            envCfg = envCfg;
            nodeCfg = node;
          })
        envCfg.nodes;
    in
      # Map over environments to get a list of node sets, then flatten/merge them into one set
      inputs.nixpkgs.lib.foldl' (acc: set: acc // set) {} (
        inputs.nixpkgs.lib.mapAttrsToList (name: env: mkEnv env) environments
      )
      // {
        nas = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {envCfg = environments.lab;};
          modules = [
            self.nixosModules.default
            ./hosts/nas
          ];
        };

        ryan-desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.nixosModules.default
            ./hosts/ryan-desktop
          ];
          specialArgs = {
            inherit inputs;
          };
        };

        dell-laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.nixosModules.default
            ./hosts/dell-laptop
          ];
          specialArgs = {
            inherit inputs;
          };
        };
      };

    nixidyEnvs."x86_64-linux" = inputs.nixidy.lib.mkEnvs {
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      extraSpecialArgs = {
        generators = inputs.nixidy.packages.x86_64-linux.generators;
        envCfg = environments.lab;
      };
      charts = inputs.nixhelm.chartsDerivations.x86_64-linux;
      envs = {
        dev.modules = [./modules/nixidy ./k3s/dev.nix];
      };
    };

    packages."x86_64-linux" = {
      nixidy = inputs.nixidy.packages."x86_64-linux".default;

      proxmoxBaseIso = let
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
      in
        pkgs.fetchurl {
          url = "https://enterprise.proxmox.com/iso/proxmox-ve_9.1-1.iso";
          hash = "sha256-bY9a/HjAxmgS1ycs3nyLmL5+tUQBzrBFQA2wXrWubSI=";
        };

      proxmoxAnswerToml = let
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
      in
        pkgs.writeText "answer.toml" ''
          [global]
          keyboard = "en-us"
          country = "us"
          fqdn = "proxmox.${environments.lab.domain}"
          mailto = "admin@${environments.lab.domain}"
          timezone = "America/Chicago"
          root_password_hashed = "__ROOT_PASSWORD_HASH__"

          [network]
          source = "from-answer"
          cidr = "${environments.lab.network.fixed_ips.proxmox}/${toString environments.lab.network.prefixLength}"
          gateway = "${environments.lab.network.gateway}"
          dns = "${builtins.elemAt environments.lab.network.nameservers 0}"
          filter.ID_NET_NAME = "en*"

          [disk-setup]
          filesystem = "ext4"
          disk_list = ["vda"]

          [first-boot]
          source = "from-iso"
          ordering = "fully-up"
        '';

      labInstallerIso = let
        iso = inputs.nixos-generators.outputs.nixosGenerate {
          system = "x86_64-linux";
          format = "install-iso";
          modules = [
            ({
              lib,
              pkgs,
              ...
            }: {
              # Enable serial console for 'virsh console'
              boot.kernelParams = ["console=ttyS0,115200n8"];
              boot.loader.timeout = lib.mkForce 0;
              users.users.root.openssh.authorizedKeys.keys = [
                (lib.fileContents ../secrets/keys/desktop/public)
                (lib.fileContents ../secrets/keys/laptop/public)
              ];
              services.openssh.enable = true;
              networking.hostName = "lab-installer";
            })
          ];
        };
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
      in
        pkgs.runCommand "lab-installer-iso-stable" {} ''
          mkdir -p $out/iso
          ln -s ${iso}/iso/*.iso $out/iso/installer.iso
        '';

      lab_tf = inputs.terranix.lib.terranixConfiguration {
        system = "x86_64-linux";
        modules = [
          ./terranix/lab.nix
          ({...}: {
            my.lab = {
              inherit (environments.lab) domain;
              inherit (environments.lab.network) gateway prefixLength dhcp_range;
              nixos-iso = self.outputs.packages.x86_64-linux.labInstallerIso;
              mainDisk = environments.lab.defaultMainDisk;
            };
          })
        ];
      };

      nas_tf = inputs.terranix.lib.terranixConfiguration {
        system = "x86_64-linux";
        modules = [
          ./terranix/nas.nix
          ({...}: {
            my.nas = {
              nixos-iso = self.outputs.packages.x86_64-linux.labInstallerIso;
              proxmox_endpoint = "https://${environments.lab.network.fixed_ips.proxmox}:8006/";
            };
          })
        ];
      };
    };

    apps."x86_64-linux" = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      opentofu = pkgs.opentofu;
      mkTfApp = {
        action,
        tfConfig,
        path,
      }: {
        type = "app";
        program = toString (pkgs.writers.writeBash "${action}" ''
          mkdir -p ${path}
          if [[ -e "${path}/main.tf.json" ]]; then rm -f "${path}/main.tf.json"; fi
          cp ${tfConfig} "${path}/main.tf.json" \
            && ${opentofu}/bin/tofu -chdir=${path} init \
            && ${opentofu}/bin/tofu -chdir=${path} ${action}
        '');
      };

      buildProxmoxIsoScript = pkgs.writeShellApplication {
        name = "build-proxmox-iso";
        runtimeInputs = [pkgs.sops pkgs.proxmox-auto-install-assistant pkgs.xorriso];
        text = ''
          set -eou pipefail

          BOLD='\033[1m'
          GREEN='\033[0;32m'
          BLUE='\033[0;34m'
          YELLOW='\033[1;33m'
          RESET='\033[0m'

          log() { echo -e "''${BOLD}''${BLUE}[*]''${RESET} $1"; }
          success() { echo -e "''${BOLD}''${GREEN}[+]''${RESET} $1"; }
          warn() { echo -e "''${BOLD}''${YELLOW}[!]''${RESET} $1"; }

          BASE_ISO="${self.packages.x86_64-linux.proxmoxBaseIso}"
          TEMPLATE_FILE="${self.packages.x86_64-linux.proxmoxAnswerToml}"

          log "Decrypting password hash from SOPS..."
          if ! [ -f "secrets/passwords.yaml" ]; then
            warn "secrets/passwords.yaml not found. Please run this from the project root."
            exit 1
          fi
          HASH=$(sops -d --extract '["passwords"]["ryan"]' secrets/passwords.yaml)

          log "Preparing staging directory..."
          STAGING_DIR=$(mktemp -d)
          trap 'rm -rf "$STAGING_DIR"' EXIT

          log "Injecting decrypted hash into answer.toml..."
          sed "s|__ROOT_PASSWORD_HASH__|$HASH|g" "$TEMPLATE_FILE" > "$STAGING_DIR/answer.toml"

          log "Creating first-boot script for VFIO IOMMU workaround..."
          cat << 'EOF' > "$STAGING_DIR/first-boot.sh"
          #!/usr/bin/env bash
          echo "Applying nested virtualization VFIO interrupt workaround..."
          echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/iommu_unsafe.conf
          update-initramfs -u -k all
          EOF

          chmod +x "$STAGING_DIR/first-boot.sh"

          log "Copying base ISO to writable staging area..."
          cp "$BASE_ISO" "$STAGING_DIR/base.iso"
          chmod +w "$STAGING_DIR/base.iso"

          log "Running proxmox-auto-install-assistant..."
          proxmox-auto-install-assistant prepare-iso "$STAGING_DIR/base.iso" \
            --fetch-from iso \
            --answer-file "$STAGING_DIR/answer.toml" \
            --on-first-boot "$STAGING_DIR/first-boot.sh" \
            --output ./proxmox-custom-installer.iso

          success "Custom Proxmox ISO successfully built at: ./proxmox-custom-installer.iso"
        '';
      };
    in {
      build-proxmox-iso = {
        type = "app";
        program = "${buildProxmoxIsoScript}/bin/build-proxmox-iso";
      };
      tf.lab.apply = mkTfApp {
        action = "apply";
        tfConfig = self.outputs.packages.x86_64-linux.lab_tf;
        path = "terraform/lab";
      };
      tf.lab.destroy = mkTfApp {
        action = "destroy";
        tfConfig = self.outputs.packages.x86_64-linux.lab_tf;
        path = "terraform/lab";
      };
    };

    devShells."x86_64-linux".default = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
      pkgs.mkShell {
        buildInputs = [
          inputs.nixidy.packages."x86_64-linux".default
          pkgs.opentofu
          pkgs.go-task
        ];
      };

    checks."x86_64-linux" = {
      ssh-test = mkTest ./tests/ssh-connectivity.nix;
    };

    homeConfigurations = {
      "ryan@desktop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [
          self.homeManagerModules.default
          {nixpkgs.overlays = [inputs.neovim-nightly-overlay.overlays.default];}
          ./home/ryan/desktop.nix
        ];
        extraSpecialArgs = {
          inherit (inputs) ags;
        };
      };

      "ryan@laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [
          self.homeManagerModules.default
          ./home/ryan/laptop.nix
        ];
        extraSpecialArgs = {
          inherit (inputs) ags;
        };
      };
    };
  };
}
