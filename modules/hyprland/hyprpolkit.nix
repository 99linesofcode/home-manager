{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.hyprpolkitagent;
in
with lib;
{
  options = {
    home.hyprpolkitagent.enable = mkEnableOption "hyprpolkitagent polkit authentication daemon";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprpolkitagent
    ];

    systemd.user.services.hyprpolkit = mkIf cfg.enable {
      Unit = {
        Description = "Hyprland Polkit Authentication Agent";
        Documentation = "https://github.com/hyprwm/hyprpolkitagent";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
      };

      Service = {
        ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
        Slice = "session.slice";
        TimeoutStopSec = "5sec";
        Restart = "on-failure";
      };
    };
  };
}
