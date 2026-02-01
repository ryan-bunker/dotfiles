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
    };

    homeConfigurations = {
      "ryan@desktop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [
          self.homeManagerModules.default
          ./home/ryan
          {
            my.desktop.wallpapers.targets = ["3440x1440" "1440x2560"];
            my.programs.ssh = {
              sopsKey = "ssh_key_desktop";
              publicKey = ''
                ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtZ8rdN4bP15DEbGFaL5K0lq9jQus0Ya/WMiZLg38v4 ryan.bunker@gmail.com
              '';
            };

            my.desktop.hyprlock.backgrounds = [
              {
                monitor = "DP-1";
                path = ../wallpapers/login_wallpaper_3440x1440.png;
              }
              {
                monitor = "HDMI-A-1";
                color = "$base";
              }
            ];
          }
        ];
        extraSpecialArgs = {
          inherit (inputs) ags;
        };
      };

      "ryan@laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [
          self.homeManagerModules.default
          ./home/ryan
          {
            my.desktop.wallpapers.targets = ["3840x2160"];
            my.programs.ssh = {
              sopsKey = "ssh_key_dell";
              publicKey = ''
                ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHeZJke7UzcoOJQNCFYpNlt/7wsQe+hKQI+q/DaNAHhB ryan.bunker@gmail.com
              '';
            };

            my.desktop.hyprland.enableTouchpad = true;
            my.desktop.hyprlock.backgrounds = [
              {
                monitor = "eDP-1";
                path = ../wallpapers/login_wallpaper_3840x2160.png;
              }
            ];
          }
        ];
        extraSpecialArgs = {
          inherit (inputs) ags;
        };
      };
    };
  };
}
