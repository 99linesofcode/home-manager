{
  config,
  lib,
  ...
}:
let
  cfg = config.home.gammastep;
in
with lib;
{
  options = {
    home.gammastep.enable = mkEnableOption "gammastep";
  };

  config = mkIf cfg.enable {
    services.gammastep = {
      enable = true;
      provider = "geoclue2";
      settings = {
        general = {
          adjustment-method = "wayland";
        };
      };
    };
  };
}
