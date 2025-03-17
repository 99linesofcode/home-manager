{
  config,
  lib,
  ...
}:
let
  cfg = config.home.eza;
in
with lib;
{
  options = {
    home.eza.enable = mkEnableOption "eza - modern ls alternative";
  };

  config = mkIf cfg.enable {
    programs = {
      eza = {
        enable = true;
        colors = "always";
        git = true;
        icons = "auto";
      };
    };
  };
}
