{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.zed;
in
with lib;
{
  options = {
    home.zed.enable = mkEnableOption "Zed editor";
  };

  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      extensions = [
        "docker"
        "emmet"
        "html"
        "lua"
        "nix"
        "php"
        "sh"
        "ruby"
        "toml"
        "vue"
      ];
      userSettings = {
        load_direnv = "shell_hook"; # Tell Zed to use direnv and direnv can use a flake.nix environment

        lsp = {
          rust-analyzer = {
            binary = {
              path = lib.getExe pkgs.rust-analyzer;
              path_lookup = true;
            };
          };
        };

        telemetry = {
          metrics = false;
        };

        vim_mode = true;
      };
    };
  };
}
