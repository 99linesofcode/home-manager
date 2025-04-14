{
  config,
  lib,
  ...
}:
let
  cfg = config.home.hyprlock;
in
with lib;
{
  options = {
    home.hyprlock.enable = mkEnableOption "hyprlock hyprland screen lock utility";
  };

  config = mkIf cfg.enable {
    programs = {
      hyprlock = {
        enable = true;
        settings = {
          label = [
            {
              text = "cmd[update:1000] echo $TIME";
              font_size = "128";
              font_family = "Noto Sans";
              position = "200, 300";
            }
            {
              text = "cmd[update:1000] echo $(date '+%A, %B %d')";
              font_size = "64";
              font_family = "Noto Sans";
              position = "200, 200";
            }
          ];
        };
      };
    };
  };
}
