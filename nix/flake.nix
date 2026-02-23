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
    # helper for creating kube server configuration
    mkKube = name:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          self.nixosModules.default
          ./hosts/kube/hardware-configuration.nix
          ./hosts/kube/${name}.nix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };

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

    nixosConfigurations = {
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

      kube-1 = mkKube "kube-1";
      kube-2 = mkKube "kube-2";
      kube-3 = mkKube "kube-3";

      lab-kube-1 = mkKube "lab-kube-1";
      lab-kube-2 = mkKube "lab-kube-2";
      lab-kube-3 = mkKube "lab-kube-3";
    };

    nixidyEnvs."x86_64-linux" = inputs.nixidy.lib.mkEnvs {
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      extraSpecialArgs.generators = inputs.nixidy.packages.x86_64-linux.generators;
      charts = inputs.nixhelm.chartsDerivations.x86_64-linux;
      envs = {
        dev.modules = [./modules/nixidy ./k3s/dev.nix];
      };
    };

    packages."x86_64-linux" = {
      nixidy = inputs.nixidy.packages."x86_64-linux".default;
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
          ({...}: {my.lab.nixos-iso = self.outputs.packages.x86_64-linux.labInstallerIso;})
        ];
      };
    };

    apps."x86_64-linux" = let
      opentofu = nixpkgs.legacyPackages.x86_64-linux.opentofu;
      mkTfApp = {
        action,
        tfConfig,
        path,
      }: {
        type = "app";
        program = toString (nixpkgs.legacyPackages.x86_64-linux.writers.writeBash "${action}" ''
          mkdir -p ${path}
          if [[ -e "${path}/main.tf.json" ]]; then rm -f "${path}/main.tf.json"; fi
          cp ${tfConfig} "${path}/main.tf.json" \
            && ${opentofu}/bin/tofu -chdir=${path} init \
            && ${opentofu}/bin/tofu -chdir=${path} ${action}
        '');
      };
    in {
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
