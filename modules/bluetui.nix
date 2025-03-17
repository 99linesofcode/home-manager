{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.bluetui;
in
with lib;
{
  options = {
    home.bluetui.enable = mkEnableOption "bluetui bluetooth manager";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bluetui
    ];
  };
}
