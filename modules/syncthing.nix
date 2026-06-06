{
  config,
  lib,
  specialArgs,
  ...
}:

let
  inherit (specialArgs) username;
  cfg = config.home.syncthing;
in
with lib;
{
  options.home.syncthing = {
    enable = mkEnableOption "syncthing";
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      settings = {
        options.urAccepted = -1; # do not submit anonymous usage data
        devices = {
          "boox" = {
            id = "O7JFX2O-SXQ2PGL-JGEPNM4-L42XPWW-A45NXOO-SSFRFJK-UIAGCC7-C5MRBQP";
          };
        };
        folders = {
          "Obsidian" = mkIf (config.home.google-drive.enable && config.home.obsidian.enable) {
            path = "/home/${username}/Documents/Google Drive/Obsidian";
            devices = [
              "boox"
            ];
          };
        };
      };
    };
  };
}
