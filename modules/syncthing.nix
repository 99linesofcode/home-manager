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
        # TODO: configure these at user level and encrypt device ids
        devices = {
          "note" = {
            id = "4CYUMEQ-DYNLFQ6-ASNQ7MX-TB6WRBA-4JPEOHJ-C5YA27Q-PVQ72CQ-AUU77Q6";
          };
          "boox" = {
            id = "O7JFX2O-SXQ2PGL-JGEPNM4-L42XPWW-A45NXOO-SSFRFJK-UIAGCC7-C5MRBQP";
          };
        };
        folders = {
          "Obsidian" = mkIf (config.home.rclone.enable && config.home.obsidian.enable) {
            path = "/home/${username}/Documents/Google Drive/Obsidian";
            devices = [
              "note"
              "boox"
            ];
          };
        };
      };
    };
  };
}
