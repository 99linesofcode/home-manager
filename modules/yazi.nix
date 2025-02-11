{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host.yazi;
in
  with lib; {
    options = {
      host.yazi.enable = mkEnableOption "yazi";
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        ueberzugpp
      ];

      programs.yazi.enable = true;
    };
  }
