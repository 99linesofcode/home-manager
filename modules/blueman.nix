{
  config,
  lib,
  ...
}:
let
  cfg = config.home.blueman;
in
with lib;
{
  options = {
    home.blueman.enable = mkEnableOption "blueman bluetooth manager";
  };

  config = mkIf cfg.enable {
    services = {
      blueman-applet.enable = true;
    };
  };
}
