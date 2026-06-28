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

  config = mkIf cfg.enable {
    home = {
      activation = {
        obsidianActivationResync =
          hm.dag.entryAfter [ "writeBoundary" ] # sh
            ''
              #!/usr/bin/env sh

              ${pkgs.coreutils}/bin/mkdir -p "$HOME/Documents/Obsidian"

              ${pkgs.rclone}/bin/rclone bisync gdrive:Obsidian/ $HOME/Documents/Obsidian/ \
              --compare size,modtime,checksum \
              --config "$XDG_CONFIG_HOME/rclone/rclone.conf" \
              --create-empty-src-dirs \
              --fix-case \
              --resync \
              --slow-hash-sync-only
            '';
      };
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
          };
          Timer = {
            OnCalendar = "*:0/5"; # every 5 minutes
            Unit = "obsidian.service";
          };
          Install = {
            WantedBy = [ "timers.target" ];
          };
        };
      };
      services = {
        obsidian = {
          Unit = {
            Description = "rclone: bidirectional syncing of Obsidian.md";
            Documentation = "man:rclone(1)";
            After = [ "network-online.target" ];
            Wants = [ "network-online.target" ];
          };
          Service = {
            Type = "oneshot";
            Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Documents/Obsidian";
            ExecStart = # sh
              ''
                ${pkgs.rclone}/bin/rclone bisync gdrive:Obsidian/ "%h/Documents/Obsidian" \
                --compare size,modtime,checksum \
                --config "%h/.config/rclone/rclone.conf" \
                --conflict-resolve newer \
                --create-empty-src-dirs \
                --fix-case \
                --max-lock 2m \
                --recover \
                --resilient \
                --slow-hash-sync-only
              '';
          };
        };
      };
    };
  };
}
