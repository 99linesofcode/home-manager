{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.obsidian;
in
with lib;
{
  options = {
    home.obsidian.enable = mkEnableOption "obsidian.md";
  };

  # TODO: initial bisync run with --resync to setup rclone working directory
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        obsidian
      ];
    };

    systemd.user = mkIf config.home.rclone.enable {
      timers = {
        obsidian = {
          Unit = {
            Description = "rclone: trigger bidirectional syncing of Obsidian.md";
            Documentation = "man:rclone(1)";
            After = [ "network-online.target" ];
            Wants = [ "timers.target" ];
          };
          Timer = {
            OnCalendar = "*:0/5";
            Unit = "obsidian";
          };
        };
      };
      services = {
        obsidian = {
          Unit = {
            Description = "rclone: bidirectional syncing of Obsidian.md";
            Documentation = "man:rclone(1)";
            Wants = [ "network-online.target" ];
          };
          Service = {
            Type = "forking";
            Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Documents/Obsidian";
            ExecStart = ''
              ${pkgs.rclone}/bin/rclone bisync \
              gdrive:Obsidian/ %h/Documents/Obsidian \
              --config %h/.config/rclone/rclone.conf \
              --conflict-resolve newer \
              --drive-skip-shortcuts \
              --drive-skip-dangling-shortcuts \
              --fast-list
            '';
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
    };
  };
}
