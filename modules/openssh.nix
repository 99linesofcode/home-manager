{
  config,
  lib,
  specialArgs,
  ...
}: let
  inherit (specialArgs) hostname username;
  cfg = config.home.openssh;
in
  with lib; {
    options = {
      home.openssh.enable = mkEnableOption "openssh";
    };

    config = mkIf cfg.enable {
      sops.secrets = {
        "ssh/id_ed25519" = {
          format = "binary";
          sopsFile = ../hosts/${hostname}/users/${username}/secrets/id_ed25519;
          path = config.home.homeDirectory + "/.ssh/id_ed25519";
          mode = "600";
        };
        "ssh/id_ed25519.pub" = {
          format = "binary";
          sopsFile = ../hosts/${hostname}/users/${username}/secrets/id_ed25519.pub;
          path = config.home.homeDirectory + "/.ssh/id_ed25519.pub";
          mode = "600";
        };
      };

      programs.ssh = {
        enable = true;
      };
    };
  }
