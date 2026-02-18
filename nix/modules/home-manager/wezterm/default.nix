{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.programs.wezterm;
in {
  options.my.programs.wezterm = {
    enable = lib.mkEnableOption "Enable wezterm terminal emulator";
  };

  config = lib.mkIf cfg.enable {
    programs.wezterm = {
      enable = true;

      extraConfig = let
        weztermOpts = {};
      in ''
        -- 1. Convert Nix set to a Lua table
        local nix_options = ${lib.generators.toLua {} weztermOpts}

        -- 2. Add the auto-generated catppuccin variables to our options
        -- (these are injected above this config block by the catppuccin module)
        nix_options.catppuccin = {
          plugin = catppuccin_plugin,
          config = catppuccin_config,
        }

        -- 3. Load the external config file from the Nix store
        local main_module = dofile("${./main.lua}")

        -- 4. Execute the function and return the config to wezterm
        return main_module(nix_options)
      '';
    };
  };
}
