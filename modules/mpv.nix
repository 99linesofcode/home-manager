{
  config,
  lib,
  ...
}:
let
  cfg = config.home.mpv;
in
with lib;
{
  options = {
    home.mpv.enable = mkEnableOption "mpv media player";
  };

  config = mkIf cfg.enable {
    programs.mpv = {
      enable = true;
      config = {
        hdr-compute-peak = "no";
        hwdec = "auto";
        osd-font = "sans-serif";
        slang = "eng,en";
        sub-auto = "fuzzy";
        sub-font = "sans-serif";
        sub-border-size = 1;
        sub-color = "#CDCDCD";
        sub-scale = 0.5;
        sub-shadow-color = "#000000";
        sub-shadow-offset = 2;
      };
    };
  };
}
