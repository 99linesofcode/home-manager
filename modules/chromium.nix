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
      captive-browser.enable = mkEnableOption "captive-browser";
    };
  };

  config = mkIf cfg.enable {
    programs = {
      chromium.enable = true;
      captive-browser.enable = mkIf cfg.captive-browser.enable;
    };
  };
}
