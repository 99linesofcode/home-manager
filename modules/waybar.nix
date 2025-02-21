{
  config,
  lib,
  ...
}:
let
  cfg = config.home.waybar;
in
with lib;
{
  options = {
    home.waybar.enable = mkEnableOption "waybar";
  };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings = [
        {
          "height" = 16;
          "layer" = "top";
          "margin-bottom" = 0;
          "margin-left" = 0;
          "margin-right" = 0;
          "margin-top" = 0;
          "spacing" = 0;

          "modules-left" = [
            "hyprland/workspaces"
            "hyprland/window"
          ];

          "modules-center" = [
            "wlr/taskbar"
          ];

          "modules-right" = [
            "idle_inhibitor"
            "cpu"
            "memory"
            "pulseaudio"
            "network"
            "bluetooth"
            "backlight"
            "battery"
            "clock"
            "clock#date"
            "tray"
          ];

          "hyprland/workspaces" = {
            "on-click" = "activate";
            "all-outputs" = false;
            "format" = "{icon}";
            "format-icons" = {
              "1" = "1";
              "2" = "2";
              "3" = "3";
              "4" = "4";
              "5" = "5";
              "6" = "6";
              "active" = "";
            };
            "persistent-workspaces" = {
              "*" = 6;
            };
          };

          "hyprland/window" = {
            "separate-outputs" = true;
          };

          "wlr/taskbar" = {
            "format" = "{icon}";
            "icon-size" = 18;
            "tooltip-format" = "{title}";
            "on-click" = "activate";
            "on-click-middle" = "close";
            "ignore-list" = [ ];
            "app_ids-mapping" = { };
            "rewrite" = { };
          };

          "idle_inhibitor" = {
            "format" = "{icon}";
            "format-icons" = {
              "activated" = "";
              "deactivated" = "";
            };
          };

          "cpu" = {
            "format" = "CPU {usage}% ";
          };

          "memory" = {
            "format" = "RAM {}% ";
          };

          "pulseaudio" = {
            "format" = "{icon} {volume}%  {format_source}";
            "format-muted" = " off  {format_source}";
            "format-source" = " on";
            "format-source-muted" = " off";
            "format-icons" = {
              "headphone" = " ";
              "hands-free" = " ";
              "headset" = " ";
              "phone" = "";
              "portable" = "";
              "car" = "";
              "default" = [
                ""
                " "
                " "
              ];
            };
            "on-click" = "pwvucontrol";
          };

          "network" = {
            "format" = "{ifname}";
            "format-wifi" = "   {signalStrength}%";
            "format-ethernet" = "  {ipaddr}";
            "format-disconnected" = "";
            "tooltip-format" = " {ifname} via {gwaddri}";
            "tooltip-format-wifi" = "   {essid} ({signalStrength}%)";
            "tooltip-format-ethernet" = "  {ifname} ({ipaddr}/{cidr})";
            "tooltip-format-disconnected" = "Disconnected";
            "max-length" = 50;
            "on-click" = "iwgtk";
          };

          "bluetooth" = {
            "format" = " {status}";
            "format-off" = "󰂲 off";
            "format-disabled" = "󰂲 disabled";
            "format-connected" = " {num_connections}";
            "tooltip-format" = "{device_alias}";
            "tooltip-format-connected" = "󰂰 {device_enumerate}";
            "tooltip-format-enumerate-connected" = "{device_alias}";
            "on-click" = "blueman-manager";
          };

          "battery" = {
            "interval" = 1;
            "states" = {
              "warning" = 30;
              "critical" = 15;
            };
            "format" = "{icon}  {capacity}%";
            "format-charging" = "  {capacity}%";
            "format-plugged" = "   {capacity}%";
            "format-icons" = [
              " "
              " "
              " "
              " "
              " "
            ];
          };

          "backlight" = {
            "device" = "intel_backlight";
            "format" = "{icon}  {percent}%";
            "format-icons" = [
              "󰃛"
              "󰃝"
              "󰃞"
              "󰃟"
              "󰃠"
            ];
            "states" = {
              "off" = 0;
              "low" = 20;
              "medium" = 60;
              "high" = 80;
              "full" = 100;
            };
          };

          "clock" = {
            "format" = "{:%H:%M:%S}";
            "interval" = 1;
            "tooltip" = false;
          };

          "clock#date" = {
            "format" = "{:%d-%m-%Y}";
            "tooltip-format" = "<tt><small>{calendar}</small></tt>";
            "calendar" = {
              "format" = {
                "weekdays" = "<span color='#E0AF68'>{}</span>";
                "months" = "<span color='#FFEAD3'>{}</span>";
                "weeks" = "<span color='#C3E88D'>W{}</span>";
                "today" = "<span color='#FF6699'><b>{}</b></span>";
              };
              "mode" = "month";
              "weeks-pos" = "left";
            };
          };

          "tray" = {
            "icon-size" = 16;
            "spacing" = 10;
          };
        }
      ];
    };
  };
}
