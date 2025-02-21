{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.pwvucontrol;
in
with lib;
{
  options = {
    home.pwvucontrol.enable = mkEnableOption "pipewire volume control";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pwvucontrol
    ];
  };
}
