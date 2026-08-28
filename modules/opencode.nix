{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  cfg = config.home.opencode;
in
with lib;
{
  options = {
    home.opencode = {
      enable = mkEnableOption "opencode";
      settings = mkOption {
        type = types.attrs;
        default = {
          autoupdate = false;
          model = "openrouter/deepseek/deepseek-v4-flash-0731";
          watcher = {
            ignore = [
              ".git/**"
              "dist/**"
              "node_modules/**"
            ];
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      opencode = {
        format = "dotenv";
        sopsFile = "${self}/hosts/shared/secrets/opencode.env";
      };
      # TODO: possibly read secrets from a predefined auth.json file such as the one below?
      # "opencode/auth.json" = {The
      #   format = "json";
      #   sopsFile = "${self}/hosts/shared/secrets/opencode";
      #   path = "${config.xdg.stateHome}/opencode/auth.json";
      # };
    };

    programs = {
      opencode = {
        enable = true;
        enableMcpIntegration = true;
        settings = cfg.settings;
      };
      zsh.initContent = mkIf config.home.zsh.enable (
        mkOrder 500 # sh
          ''
            export $(cat ${config.sops.secrets.opencode.path})
          ''
      );
    };
  };
}
