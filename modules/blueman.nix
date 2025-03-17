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

  # Note that for the applet to work, the blueman service should be enabled system-wide
  config = mkIf cfg.enable {
    services = {
      blueman-applet.enable = true;
    };
  };
}
