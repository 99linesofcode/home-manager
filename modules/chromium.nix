{
  config,
  lib,
  ...
}:
let
  cfg = config.home.chromium;
in
with lib;
{
  options = {
    home.chromium = {
      enable = mkEnableOption "chromium";
    };
  };

  config = mkIf cfg.enable {
    programs = {
      chromium.enable = true;
    };
  };
}
