{
  config,
  lib,
  ...
}:
let
  cfg = config.home.hypridle;
in
with lib;
{
  options = {
    home.hypridle.enable = mkEnableOption "hypridle daemon";
  };

  config = mkIf cfg.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          {
            timeout = 300; # 5 minutes
            on-timeout = "brightnessctl -s set 10";
            on-resume = "brightnessctl -r";
          }
          {
            timeout = 600; # 10 minutes
            on-timeout = "loginctl lock-session";
            on-resume = "brightnessctl -r";
          }
          {
            timeout = 900; # 15 minutes
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
          }
          {
            timeout = 1800; # 30 minutes
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
