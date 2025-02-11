{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host.dunst;
in
  with lib; {
    options = {
      host.dunst.enable = mkEnableOption "dunst notifications manager";
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        libnotify
      ];

      services.dunst = {
        enable = true;
      };
    };
  }
