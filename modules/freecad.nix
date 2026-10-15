{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.freecad;
in
with lib;
{
  options = {
    home.freecad.enable = mkEnableOption "freecad";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        freecad
      ];
    };

    programs = {
      mcp = {
        enable = true;
        servers = {
          freecad = {
            type = "local";
            command = lib.getExe' pkgs.uv "uvx";
            args = [
              "freecad-mcp"
            ];
          };
        };
      };
    };
  };
}
