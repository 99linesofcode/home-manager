{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.lazysql;
in
with lib;
{
  options = {
    home.lazysql.enable = mkEnableOption "lazysql";
  };

  config = mkIf cfg.enable {
    programs.lazysql = {
      enable = true;
    };
  };
}
