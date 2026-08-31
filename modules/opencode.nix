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
          default_agent = "orchestrator";
          agent = {
            build.disable = true;
            plan.disable = true;
            general.disable = true;
            explore.disable = true;
            scout.disable = true;
          };
          watcher = {
            ignore = [
              ".direnv/**"
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
    };

    programs = {
      opencode = {
        enable = true;
        enableMcpIntegration = true;
        agents = ../.opencode/agents;
        settings = cfg.settings;
        skills = ../.opencode/skills;
      };
      mcp = {
        enable = true;
        servers = {
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
      zsh.initContent = mkIf config.home.zsh.enable (mkAfter
      # sh
      ''
        export $(cat ${config.sops.secrets.opencode.path})
      '');
    };
  };
}
