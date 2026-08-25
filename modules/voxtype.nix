{
  config,
  lib,
  ...
}:
let
  cfg = config.home.voxtype;
in
with lib;
{
  options = {
    home.voxtype.enable = mkEnableOption "voxtype - AI powered speech-to-text daemon";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      openrouter_api_key = {
        format = "binary";
        sopsFile = "${self}/hosts/shared/secrets/openrouter_api_key";
      };
    };

    services.voxtype = {
      enable = true;
      audio.feedback.enabled = false;
      output = {
        fallback_to_clipboard = true;
        mode = "type";
        notification = {
          on_recording_start = true;
          on_recording_end = false;
          on_transcription = false;
        };
      };
      whisper = {
        language = "auto";
        remote_endpoint = "https//openrouter.ai/api";
      };
    };

    programs.zsh.initContent = mkIf config.home.zsh.enable (
      mkOrder 500 # sh
        ''
          export VOXTYPE_WHISPER_API_KEY=$(cat ${config.sops.secrets.openrouter_api_key.path})
        ''
    );

    wayland.windowManager.hyprland.settings = mkIf config.home.hyprland.enable {
      bind = [
        "SUPER, R, exec, voxtype record start"
      ];
      bindr = [
        "SUPER, R, exec, voxtype record stop"
      ];
    };
  };
}
