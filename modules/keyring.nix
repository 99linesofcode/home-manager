{
  config,
  lib,
  ...
}: let
  cfg = config.host.keyring;
in
  with lib; {
    options = {
      host.keyring.enable = mkEnableOption "gnome-keyring";
    };

    config = mkIf cfg.enable {
      services = {
        gnome-keyring = {
          enable = true;
          components = [
            "pkcs11"
            "secrets"
            "ssh"
          ];
        };
      };
    };
  }
