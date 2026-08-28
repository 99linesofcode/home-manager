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
      # "opencode/auth.json" = {
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
      mcp = {
        enable = true;
        servers = {
          # github = {
          #   type = "remote";
          #   url = "https://api.githubcopilot.com/mcp";
          #   oauth = false;
          #   headers = {
          #     "Authorization" = "Bearer {env:GITHUB_PERSONAL_ACCESS_TOKEN}";
          #   };
          # };
          gmail = {
            type = "remote";
            url = "https://gmailmcp.googleapis.com/mcp/v1";
          };
          google-drive = {
            type = "remote";
            url = "https://drivemcp.googleapis.com/mcp/v1";
          };
          google-calendar = {
            type = "remote";
            url = "https://calendarmcp.googleapis.com/mcp/v1";
          };
          todoist = {
            type = "remote";
            url = "https://ai.todoist.net/mcp";
          };
        };
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
