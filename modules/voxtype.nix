{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}:
let
  cfg = config.home.voxtype;
in
with lib;
{
  imports = [
    "${inputs.home-manager-unstable}/modules/services/voxtype.nix"
  ];

  disabledModules = [
    "services/voxtype.nix"
  ];

  options = {
    home.voxtype.enable = mkEnableOption "voxtype - AI powered speech-to-text daemon";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      voxtype = {
        format = "dotenv";
        sopsFile = "${self}/hosts/shared/secrets/voxtype.env";
      };
    };

    services.voxtype = {
      enable = true;
      package = pkgs.voxtype-onnx;
      settings = {
        hotkey.enabled = false;
        audio.feedback.enabled = false;
        engine = "whisper";
        osd.enabled = false;
        output = {
          fallback_to_clipboard = true;
          mode = "type";
          notification = {
            on_recording_start = true;
            on_recording_end = true;
            on_transcription = false;
          };
        };
        parakeet = {
          model = "parakeet-tdt-0.6b-v3";
          model_type = "tdt";
        };
        whisper = rec {
          mode = "remote";
          model = remote_model;
          remote_endpoint = "https://openrouter.ai/api";
          remote_model = "mistralai/voxtral-small-24b-2507-stt";
        };
      };
    };

    systemd.user.services.voxtype = {
      Service = {
        EnvironmentFile = config.sops.secrets.voxtype.path;
      };
    };

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
