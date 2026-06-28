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
      };
    };
  };
}
