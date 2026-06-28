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
    home = {
      file."${config.xdg.configHome}/rclone/filter-file.txt".text = ''
        - .direnv/
        - .git/
        - .github/
        - .Trash-1000/
        - node_modules/
        - pnpm-lock.yaml
        - vendor/
        - composer.lock
      '';

      packages = with pkgs; [
        fuse
        rclone
      ];
    };

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
