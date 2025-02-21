{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "wl-paste -w cliphist store" # TODO: switch to clipse or stick with rofi and cliphist?
    ];

    monitor = [
      "eDP-1, highres, 0x0, 2"
    ];

    workspace = [
      "eDP-1, 1"
    ];

    cursor.no_hardware_cursors = true;

    decoration = {
      rounding = 3;
      blur = {
        size = 3;
        xray = true;
      };
      shadow = {
        range = 30;
        color = "0x66000000";
      };
    };
    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    general = {
      gaps_out = 10;
    };
    gestures.workspace_swipe = true;

    input = {
      kb_options = "caps:swapescape";
      sensitivity = 0.2;
      touchpad.natural_scroll = true;
    };

    master.new_status = "master";
    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      enable_swallow = true;
    };

    xwayland.force_zero_scaling = true;
  };
}
