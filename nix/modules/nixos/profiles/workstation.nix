{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.profiles.workstation;
in {
  options = {
    my.profiles.workstation.enable = lib.mkEnableOption "Workstation Machine Profile";
  };

  config = lib.mkIf cfg.enable {
    # Use the systemd-boot EFI boot loader.
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    networking.networkmanager.enable = true;

    time.timeZone = "US/Central";

    # Allow installing unfree packages.
    nixpkgs.config.allowUnfree = true;
    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = true;
    };

    # TODO: move this to a separate module
    sops.secrets.my_password.neededForUsers = true;
    users.users.ryan = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel" # Enable ‘sudo’ for the user.
      ];
      hashedPasswordFile = config.sops.secrets.my_password.path;
    };

    # setup zsh as the default system shell - enabling it here is required so it functions properly
    # full configuration happens as part of home-manager
    programs.zsh = {
      enable = true;
      enableCompletion = true;
    };
    users.defaultUserShell = pkgs.zsh;

    environment.systemPackages = with pkgs; [
      btrfs-progs
      git
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
    ];

    my.desktop = {
      hyprland.enable = true;
      sddm.enable = true;
    };

    catppuccin = {
      enable = true;
      flavor = "macchiato";
      accent = "peach";
    };
  };
}
