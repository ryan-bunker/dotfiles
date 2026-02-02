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
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
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
  } @ inputs: {
    nixosModules = {
      default = {...}: {
        imports = [
          inputs.catppuccin.nixosModules.catppuccin
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
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

      kube-1 = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          self.nixosModules.default
          ./hosts/kube/kube-1.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ryan = {
              imports = [
                self.homeManagerModules.default
                ./home/ryan/server.nix
              ];
            };
          }
        ];
        specialArgs = {
          inherit inputs;
        };
      };
    };

    checks.${system}.homelabTest = import ./tests/homelab-cluster.nix {
      pkgs = nixpkgs.legacyPackages.${system};
      inherit self;
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
