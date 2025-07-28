{
  description = "Home Manager configuration of I845798";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
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
  };

  outputs = {
    nixpkgs,
    home-manager,
    alejandra,
    ...
  } @ inputs: let
    mkPkgs = sys:
      import nixpkgs {
        system = sys;
        config.allowUnfree = true;
        overlays = [
          inputs.neovim-nightly-overlay.overlays.default
        ];
      };
  in {
    nixosModules = {
      home = {
        config,
        pkgs,
        ...
      } @ args:
        import ./home.nix (args // {inherit alejandra;});
    };

    homeConfigurations = {
      ryan = home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs "x86_64-linux";
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./arch-laptop.nix
        ];
      };
    };
  };
}
