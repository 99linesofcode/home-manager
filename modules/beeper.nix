{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  cfg = config.home.beeper;
in
with lib;
{
  options = {
    home.beeper = {
      enable = mkEnableOption "beeper";
      socketPath = mkOption {
        type = types.str;
        default = "/run/user/1000/opencode.sock";
        description = "Path to the opencode socket plugin's Unix socket.";
      };
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.beeper = {
      format = "dotenv";
      sopsFile = "${self}/hosts/shared/secrets/beeper.env";
    };

    home = {
      packages = with pkgs; [
        beeper
      ];
    };

    systemd.user.services."opencode-beeper-bridge@" = {
      Unit = {
        Description = "Bridge Beeper messages to the active opencode session";
      };
      Service = {
        Type = "simple";
        Restart = "no";
        WorkingDirectory = "/home/shorty/Development/opencode-beeper-bridge";
        EnvironmentFile = config.sops.secrets.beeper.path;
        Environment = [
          "BEEPER_CHAT_ID=%i"
          "OPENCODE_SOCKET_PATH=${cfg.socketPath}"
          "PATH=${lib.getBin pkgs.ffmpeg}/bin:${lib.getBin pkgs.voxtype-onnx}/bin"
        ];
        ExecStart = "${lib.getExe pkgs.bun} run src/index.ts";
        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "opencode-beeper-bridge";
      };
    };
  };
}