{
  config,
  lib,
  ...
}:
let
  cfg = config.home.zathura;
in
with lib;
{
  options.home.zathura = {
    enable = mkEnableOption "zathura";
  };

  config = mkIf cfg.enable {
    programs.zathura.enable = true;
  };
}
