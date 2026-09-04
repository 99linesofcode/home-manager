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
        audio = {
          feedback.enabled = false;
          max_duration_secs = 300;
        };
        engine = "parakeet";
        hotkey.enabled = false;
        osd.enabled = false;
        output = {
          fallback_to_clipboard = true;
          mode = "type";
          notification = {
            on_recording_start = false;
            on_recording_end = false;
            on_transcription = false;
          };
        };
        parakeet = {
          model = "parakeet-tdt-0.6b-v3";
          model_type = "tdt";
        };
        meeting = {
          enabled = true;
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

    programs.waybar = mkIf config.home.waybar.enable {
      settings.main = {
        modules-right = mkAfter [
          "custom/voxtype"
        ];

        "custom/voxtype" = {
          exec = "voxtype status --follow --format json";
          return-type = "json";
          format = "{}";
          tooltip = true;
          on-click = "systemctl --user restart voxtype";
        };
      };
      style =
        mkAfter
          # css
          ''
            #custom-voxtype {
              padding: 0 5px;
            }
            #custom-voxtype.recording {
              color: #ff5555;
              animation: pulse 1s ease-in-out infinite;
            }
            #custom-voxtype.transcribing {
              color: #f1fa8c;
            }
            #custom-voxtype.idle {
              color: #50fa7b;
            }
            #custom-voxtype.stopped {
              color: #6272a4;
            }
            @keyframes pulse {
              0% { opacity: 1; }
              50% { opacity: 0.5; }
              100% { opacity: 1; }
            }
          '';
    };

    wayland.windowManager.hyprland.settings = mkIf config.home.hyprland.enable {
      bind = [
        "SUPER, R, exec, voxtype record toggle"
      ];
    };
  };
}
