{
  config,
  lib,
  ...
}:
let
  cfg = config.home.zellij;
in
with lib;
{
  options = {
    home.zellij.enable = mkEnableOption "zellij";
  };

  config = mkIf cfg.enable {
    programs = {
      alacritty = mkIf config.programs.alacritty.enable {
        settings = {
          terminal.shell = "zellij";
        };
      };
      zellij = {
        enable = true;
        enableZshIntegration = config.programs.zsh.enable;
        settings = {
          default_layout = "compact";
          # NOTE: https://github.com/zellij-org/zellij/blob/main/zellij-utils/assets/config/default.kdl
          keybinds = {
            "normal clear-defaults=true" = {
              "bind \"Ctrl b\"" = {
                "SwitchToMode" = "Tmux";
              };
            };
            tmux = {
              "bind \"Ctrl b\"" = {
                "Write 2; SwitchToMode" = "Normal";
              };
              "bind \"Esc\"" = {
                "SwitchToMode" = "Normal";
              };
              "bind \"l\"" = {
                "SwitchToMode" = "Locked";
              };
              "bind \"p\"" = {
                "SwitchToMode" = "Pane";
              };
              "bind \"t\"" = {
                "SwitchToMode" = "Tab";
              };
              "bind \"r\"" = {
                "SwitchToMode" = "Resize";
              };
              "bind \"m\"" = {
                "SwitchToMode" = "Move";
              };
              "bind \"s\"" = {
                "SwitchToMode" = "Scroll";
              };
              "bind \"o\"" = {
                "SwitchToMode" = "Session";
              };
              "bind \"q\"" = {
                Quit = { };
              };
              "bind \"Alt h\"" = {
                "MoveFocusOrTab" = "Left";
              };
              "bind \"Alt l\"" = {
                "MoveFocusOrTab" = "Right";
              };
              "bind \"Alt j\"" = {
                "MoveFocus" = "Down";
              };
              "bind \"Alt k\"" = {
                "MoveFocus" = "Up";
              };
              "bind \"Alt =\"" = {
                "Resize" = "Increase";
              };
              "bind \"Alt -\"" = {
                "Resize" = "Decrease";
              };
            };
          };
        };
      };
    };
  };
}
