{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.home.hyprland;
in
  with lib; {
    options = {
      home.hyprland.enable = mkEnableOption "hyprland";
    };

    config = mkIf cfg.enable {
      xdg.configFile = {
        "hypr/state.conf" = {
          source = ../dotfiles/hypr/state.conf;
          force = true;
        };
        "hypr/scripts/bluetooth-toggle.sh".source = ../dotfiles/hypr/scripts/bluetooth-toggle.sh;
        "hypr/scripts/display-toggle.sh".source = ../dotfiles/hypr/scripts/display-toggle.sh;
      };

      home = {
        sessionVariables = {
          NIXOS_OZONE_WL = "1";
          # GSK_RENDERER = "gl";
        };
        packages = with pkgs; [
          brightnessctl
          grim
          hypridle
          hyprpaper
          hyprpicker
          hyprshade
          nwg-dock-hyprland
          pipewire
          polkit
          polkit_gnome
          slurp
          swappy
          waypaper
          wl-clipboard
          wireplumber
          xdg-utils
          # GUI components
          bluez # bluetooth
          bluez-tools # bluetooth
          iwgtk
          pavucontrol
          qalculate-gtk
        ];
      };

      services = {
        blueman-applet.enable = true; # bluetooth
        cliphist.enable = true;
        hyprpaper.enable = true;
        mpris-proxy.enable = true; # bluetooth
        udiskie.enable = true;
      };

      programs = {
        hyprlock.enable = true;
        # sddm.enable = true;
        wlogout.enable = true;
      };

      wayland.windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;
        systemd.enable = true;
        settings = {
          env = [
            # Theming
            "CLUTTER_BACKEND,wayland"
            "GDK_BACKEND,wayland"
            "GDK_SCALE,2"
            "SDL_VIDEODRIVER,wayland"
            "QT_AUTO_SCREEN_SCALE_FACTOR,2"
            "QT_QPA_PLATFORM,wayland;xcb"
            "QT_QPA_PLATFORMTHEME,qt6ct"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"

            # XDG
            "XDG_CURRENT_DESKTOP,Hyprland"
            "XDG_SESSION_TYPE,wayland"
            "XDG_SESSION_DESKTOP,Hyprland"

            # Nvidia
            "LIBVA_DRIVER_NAME,nvidia"
            "GBM_BACKEND,nvidia-drm"
            "__GLX_VENDOR_LIBRARY_NAME,nvidia"

            # Firefox
            "NVD_BACKEND,direct"
            "MOZ_DISABLE_RDD_SANDBOX,1"
            "MOZ_ENABLE_WAYLAND,1"
            "EGL_PLATFORM,wayland"
          ];

          # TODO: extract to each individual module
          exec-once = [
            "waybar"
            "swww-daemon"
            "swayidle -w timeout 10 'if pgrep -x swaylock; then hyprctl dispatch dpms off; fi' resume 'hyprctl dispatch dpms on'"
            "swayidle -w timeout 300 'swaylock -f -C ~/.config/swaylock/config' timeout 330 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on'"
            "udiskie &"
            "/usr/bin/dunst"
            "/usr/lib/polkit-kde-authentication-agent-1"
            "/usr/lib/pam_kwallet_init"
            "wl-paste -w cliphist store" # TODO: switch to clipse or stick with rofi and cliphist?
            "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          ];

          monitor = [
            "eDP-1,highres,0x0,2.0"
          ];

          workspace = [
            "eDP-1,1"
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

          bind = [
            # Passthrough
            "SUPER_ALT_CTRL, R, pass, ^(com\.obsproject\.Studio)$"
            "SUPER_ALT_CTRL, S, pass, ^(com\.obsproject\.Studio)$"

            # Hotkeys
            "SUPER, Q, exec, wlogout"
            "SUPER, Return, exec, alacritty"
            "SUPER, Space, exec, rofi -show-icons -show drun -l 10"
            "SUPER, E, exec, alacritty -e 'yazi'"
            "SUPER, C, exec, qalculate-gtk"
            "SUPER, D, exec, hyprpicker -na"
            "SUPER, S, exec, grim -g \"$(slurp)\" - | swappy -f - | wl-copy"
            "SUPER, V, exec, cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy"

            "SUPER_ALT, M, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
            "SUPER_ALT, B, exec, ~/.config/hypr/scripts/bluetooth-toggle.sh"

            # Fn keys
            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ", XF86AudioPrev, exec, playerctl previous"
            ", XF86AudioPlay, exec, playerctl play-pause"
            ", XF86AudioNext, exec, playerctl next"

            # Manipulate windows
            "SUPER, W, killactive"
            "SUPER, F, fullscreen"
            "SUPER_CTRL, F, togglefloating"
            "SUPER_CTRL, S, togglesplit"

            # Focus window
            "SUPER, H, movefocus, l"
            "SUPER, H, alterzorder, top"
            "SUPER, L, movefocus, r"
            "SUPER, L, alterzorder, top"
            "SUPER, K, movefocus, u"
            "SUPER, K, alterzorder, top"
            "SUPER, J, movefocus, d"
            "SUPER, J, alterzorder, top"

            # Move window
            "SUPER_CTRL, H, movewindow, l"
            "SUPER_CTRL, L, movewindow, r"
            "SUPER_CTRL, K, movewindow, u"
            "SUPER_CTRL, J, movewindow, d"

            # Cycle through windows
            "SUPER, Tab, cyclenext"
            "SUPER, Tab, alterzorder, top"
            "SUPER_SHIFT, Tab, cyclenext, prev"
            "SUPER_SHIFT, Tab, alterzorder, top"

            # Switch workspace
            "SUPER, 1, workspace, 1"
            "SUPER, 2, workspace, 2"
            "SUPER, 3, workspace, 3"
            "SUPER, 4, workspace, 4"
            "SUPER, 5, workspace, 5"
            "SUPER, 6, workspace, 6"

            # Move window to workspace
            "SUPER_SHIFT, 1, movetoworkspace, 1"
            "SUPER_SHIFT, 2, movetoworkspace, 2"
            "SUPER_SHIFT, 3, movetoworkspace, 3"
            "SUPER_SHIFT, 4, movetoworkspace, 4"
            "SUPER_SHIFT, 5, movetoworkspace, 5"
            "SUPER_SHIFT, 6, movetoworkspace, 6"

            # Scroll through workspaces
            "SUPER_SHIFT, mouse_down, workspace, e+1"
            "SUPER_SHIFT, mouse_up, workspace, e-1"
          ];

          binde = [
            # Fn keys
            ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.25 @DEFAULT_AUDIO_SINK@ 5%+"
            ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.25 @DEFAULT_AUDIO_SINK@ 5%-"
            "SUPER, P, exec, ~/.config/hypr/scripts/display-toggle.sh"
            ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"
            ", XF86MonBrightnessUp, exec, brightnessctl s 10%+"
            ", XF86KbdBrightnessDown, exec, brightnessctl s 10%+"
            ", XF86KbdBrightnessUp, exec, brightnessctl s 10%+"

            # Window resizing
            "SUPER_SHIFT, H, resizeactive, -100 0"
            "SUPER_SHIFT, J, resizeactive, 0 100"
            "SUPER_SHIFT, K, resizeactive, 0 -100"
            "SUPER_SHIFT, L, resizeactive, 100 0"
          ];

          bindm = [
            # Move/resize windows with LMB/RMB
            "SUPER, mouse:272, movewindow"
            "SUPER, mouse:273, resizewindow"
          ];
        };
      };

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        config.common = {
          "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
          "org.freedesktop.impl.portal.ScreenCast" = ["hyprland"];
          "org.freedesktop.impl.portal.Screenshot" = ["hyprland"];
          # TODO: package xdg-desktop-portal-termfilechoooser so I can use yazi as default
          "org.freedesktop.portal.FileChooser" = ["xdg-desktop-portal-gtk"];
        };
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-hyprland
        ];
      };
    };
  }
