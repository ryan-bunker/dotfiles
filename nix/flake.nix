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

    lab = import ./lab.nix {pkgs = nixpkgs.legacyPackages."x86_64-linux";};
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
    };

    packages."x86_64-linux" = {
      labInstallerIso = inputs.nixos-generators.outputs.nixosGenerate {
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
    };

    devShells."x86_64-linux".default = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
      pkgs.mkShell {
        buildInputs = [
          pkgs.terraform
        ];
      };

    apps."x86_64-linux" = {
      lab-kube-1 = {
        type = "app";
        program = "${lab.mkLabNode {
          name = "kube-1";
          macSuffix = "01";
        }}/bin/run-kube-1";
      };

      lab-kube-2 = {
        type = "app";
        program = "${lab.mkLabNode {
          name = "kube-2";
          macSuffix = "02";
        }}/bin/run-kube-2";
      };
    };

    checks."x86_64-linux" = {
      ssh-test = mkTest ./tests/ssh-connectivity.nix;
      # homelabTest = import ./tests/homelab-cluster.nix {
      #   pkgs = nixpkgs.legacyPackages.${system};
      #   inherit self;
      # };
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
