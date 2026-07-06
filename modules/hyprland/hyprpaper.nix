{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.hyprpaper;
in
with lib;
{
  options = {
    home.hyprpaper.enable = mkEnableOption "hyprpaper wayland wallpaper utility";
  };

  config = mkIf cfg.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
      };
    };

    systemd.user = mkIf config.home.google-drive.enable {
      timers = {
        wallpaper = {
          Unit = {
            Description = "hyprpaper: trigger reload random wallpaper";
          };
          Timer = {
            OnCalendar = "*:00/30";
            Unit = "wallpaper.service";
          };
          Install = {
            WantedBy = [ "timers.target" ];
          };
        };
      };
      services = {
        wallpaper = {
          Unit = {
            Description = "hyprpaper: load random wallpaper";
            After = [ "gdrive.service" ];
            Wants = [ "gdrive.service" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart =
              pkgs.writeShellScript "wallpaper-rotation" # sh
                ''
                  #!/usr/bin/env sh

                  WALLPAPER_DIRECTORY="$HOME/Documents/Google Drive/Afbeeldingen/Wallpapers"

                  hyprctl hyprpaper wallpaper ", $(find "$WALLPAPER_DIRECTORY" -type f | shuf -n 1)"
                '';
          };
        };
      };
    };
  };
}
