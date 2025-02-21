{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    bind = [
      # Passthrough OBS
      "SUPER_ALT_CTRL, R, pass, ^(com\.obsproject\.Studio)$"
      "SUPER_ALT_CTRL, S, pass, ^(com\.obsproject\.Studio)$"

      # Hotkeys
      "SUPER, Return, exec, alacritty"
      "SUPER, Space, exec, rofi -show-icons -show drun -l 10"
      "SUPER, E, exec, alacritty -e 'yazi'"
      "SUPER, D, exec, hyprpicker -na"
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
}
