{
  description = "Home Manager configuration of I845798";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alejandra = {
      url = "github:kamadorueda/alejandra/4.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosModules = {
      default = {...}: {
        imports = [
          ./modules
        ];
        _module.args = inputs // {inherit inputs;};
      };
    };

    homeManagerModules = {
      default = {...}: {
        imports = [
          inputs.catppuccin.homeModules.catppuccin
          inputs.spicetify-nix.homeManagerModules.spicetify
          inputs.ags.homeManagerModules.default
          ./modules/home-manager
        ];
        _module.args = inputs // {inherit inputs;};
      };
    };

    homeConfigurations = {
      ryan = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          self.homeManagerModules.default
          ./home/ryan
        ];
        extraSpecialArgs = {
          inherit (inputs) ags;
        };
      };
    };
  };
}
