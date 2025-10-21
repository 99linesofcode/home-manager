{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.impala;
in
with lib;
{
  options = {
    home.impala.enable = mkEnableOption "impala wifi manager";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      impala
    ];
  };
}
