{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.steam;
in
with lib;
{
  options = {
    home.steam.enable = mkEnableOption "steam";
  };

  config = mkIf cfg.enable {
    # pretty sure this is not how the issue should be resolved but
    # wine fails to display installation wizards as it is unable
    # to find a truetype font without this env variable set.
    home.sessionVariables = {
      LD_LIBRARY_PATH = "${pkgs.freetype}/lib:${pkgs.pkgsi686Linux.freetype}/lib:$LD_LIBRARY_PATH";
    };
  };
}
