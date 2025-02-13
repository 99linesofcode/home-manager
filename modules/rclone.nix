{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.rclone;
in
with lib;
{
  options = {
    home.rclone.enable = mkEnableOption "rclone";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fuse
      rclone
    ];

    # TODO: encrypt to disk using rclone config encryption?
    sops.secrets = {
      "rclone/rclone.conf" = {
        format = "binary";
        sopsFile = ../hosts/shared/secrets/rclone.conf;
        path = config.home.homeDirectory + "/.config/rclone/rclone.conf";
        mode = "600";
      };
    };

    systemd.user.services = {
      gdrive = {
        Unit = {
          Description = "rclone: Remote FUSE filesystem for Google Drive";
          Documentation = "man:rclone(1)";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
        };
        Service = {
          Type = "notify";
          Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Documents/'Google Drive'";
          ExecStart = ''
            ${pkgs.rclone}/bin/rclone mount \
            --config=%h/.config/rclone/rclone.conf \
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
          Type = "notify";
          Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Documents/Media";
          ExecStart = ''
            ${pkgs.rclone}/bin/rclone mount \
            --buffer-size 32M \
            --config=%h/.config/rclone/rclone.conf \
            --no-checksum \
            --no-modtime \
            --read-only \
            --vfs-cache-mode full \
            --vfs-fast-fingerprint \
            --vfs-read-ahead 64M \
            --umask 022 \
            gcrypt: %h/Documents/Media
          '';
          ExecStop = "/run/wrappers/bin/fusermount -u %h/Documents/Media";
        };
        Install.WantedBy = [ "default.target" ];
      };
    };
  };
}
