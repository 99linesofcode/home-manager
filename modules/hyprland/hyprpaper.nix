{
  config,
  lib,
  specialArgs,
  ...
}:
let
  inherit (specialArgs) username;
  cfg = config.home.hyprpaper;
in
with lib;
{
  options = {
    home.hyprpaper.enable = mkEnableOption "hyprpaper wayland wallpaper utility";
  };

  config = mkIf cfg.enable {
    xdg.configFile = {
      "hypr/scripts/wallpaper-rotation.sh".source = ../../dotfiles/hypr/scripts/wallpaper-rotation.sh;
    };

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
            Description = "hyprpaper: reload random wallpaper";
            After = [ "network-online.target" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "/home/${username}/.config/hypr/scripts/wallpaper-rotation.sh";
          };
        };
      };
    };
  };
}
