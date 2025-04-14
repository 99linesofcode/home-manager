{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.feh;
in
with lib;
{
  options = {
    home.feh.enable = mkEnableOption "feh - fast and light image viewer";
  };

  config = mkIf cfg.enable {
    programs.feh = with pkgs; {
      enable = true;
      package = feh.override { imlib2 = imlib2Full; };
    };
  };
}
