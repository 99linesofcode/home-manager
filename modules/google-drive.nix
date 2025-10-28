{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.google-drive;
in
with lib;
{
  options = {
    home.google-drive.enable = mkEnableOption "Google Drive";
  };

  config = mkIf cfg.enable {
    systemd.user.services = mkIf config.home.rclone.enable {
      gdrive = {
        Unit = {
          Description = "rclone: Remote FUSE filesystem for Google Drive";
          Documentation = "man:rclone(1)";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
        };
        Service = {
          Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Documents/'Google Drive'";
          ExecStart = # sh
            ''
              ${pkgs.rclone}/bin/rclone mount \
              --config %h/.config/rclone/rclone.conf \
              --umask 022 \
              --vfs-cache-mode writes \
              gdrive: %h/Documents/'Google Drive'
            '';
          ExecStop = "/run/wrappers/bin/fusermount -u %h/Documents/'Google Drive'";
        };
        Install.WantedBy = [ "default.target" ];
      };
      gcrypt = {
        Unit = {
          Description = "rclone: Remote FUSE filesystem for media files";
          Documentation = "man:rclone(1)";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
        };
        Service = {
          Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Documents/Media";
          ExecStart = # sh
            ''
              ${pkgs.rclone}/bin/rclone mount \
              --buffer-size 32M \
              --config %h/.config/rclone/rclone.conf \
              --no-checksum \
              --no-modtime \
              --umask 022 \
              --vfs-cache-mode full \
              --vfs-fast-fingerprint \
              --vfs-read-ahead 64M \
              gcrypt: %h/Documents/Media
            '';
          ExecStop = "/run/wrappers/bin/fusermount -u %h/Documents/Media";
        };
        Install.WantedBy = [ "default.target" ];
      };
    };
  };
}
