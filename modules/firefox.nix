{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
let
  inherit (specialArgs) username;
  cfg = config.home.firefox;
in
with lib;
{
  options.home.firefox = with types; {
    enable = mkEnableOption "firefox";
    defaultApplication = {
      enable = mkEnableOption "MIME default application";
      mimeTypes = mkOption {
        description = "MIME types to be the default application for";
        type = listOf str;
        default = [
          "application/x-extension-htm"
          "application/x-extension-html"
          "application/x-extension-shtml"
          "application/x-extension-xht"
          "application/x-extension-xhtml"
          "application/xhtml+xml"
          "text/html"
          "x-scheme-handler/about"
          "x-scheme-handler/chrome"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/unknown"
        ];
      };
    };
  };

  config = mkIf cfg.enable {
    home.hyprland.uwsm.extraLines = # sh
      ''
        export MOZ_ENABLE_WAYLAND=1
        export MOZ_DISABLE_RDD_SANDBOX=1
        export MOZ_DRM_DEVICE="/dev/dri/card0"
        export MOZ_USE_XINPUT2=1
      '';

    programs.firefox = {
      enable = true;
      configPath = "${config.xdg.configHome}/mozilla/firefox";
      languagePacks = [
        "en-US"
        "en-GB"
        "nl"
      ];
      policies = {
        AppAutoUpdate = false;
        BackgroundAppUpdate = false;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DNSOverHTTPS = {
          Enabled = true;
          ProviderUrl = "dns.quad9.net";
          Locked = true;
          Fallback = true;
        };
        DontCheckDefaultBrowser = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          EmailTracking = true;
          Fingerprinting = true;
        };
        HardwareAcceleration = true;
        NetworkPrediction = false; # DNS prefetching
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
        PostQuantumKeyAgreementEnabled = true;

        ExtensionSettings =
          let
            moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
          in
          {
            "*".installation_mode = "blocked";

            "nl-NL@dictionaries.addons.mozilla.org" = {
              install_url = moz "woordenboek-nederlands";
              installation_mode = "force_installed";
              updates_disabled = true;
            };

            "{d187b435-812e-4813-a93e-edccc4118f9d}" = {
              install_url = moz "british-english-dictionary-gb";
              installation_mode = "force_installed";
              updates_disabled = true;
            };

            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              install_url = moz "bitwarden-password-manager";
              installation_mode = "force_installed";
              updates_disabled = true;
            };

            "addon@darkreader.org" = {
              install_url = moz "darkreader";
              installation_mode = "force_installed";
              updates_disabled = true;
            };

            "{7efbd09d-90ad-47fa-b91a-08c472bdf566}" = {
              install_url = moz "fake-filler";
              installation_mode = "force_installed";
              updates_disabled = true;
            };

            "{2f182d41-fd03-4a6d-938d-081419586c37}" = {
              install_url = moz "google-analytics-opt-out";
              installation_mode = "force_installed";
              updates_disabled = true;
            };

            "sponsorBlocker@ajay.app" = {
              install_url = moz "sponsorblock";
              installation_mode = "force_installed";
              updates_disabled = true;
            };

            "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
              install_url = moz "return-youtube-dislikes";
              installation_mode = "force_installed";
              updates_disabled = true;
            };

            "{5caff8cc-3d2e-4110-a88a-003cc85b3858}" = {
              install_url = moz "vue-js-devtools";
              installation_mode = "force_installed";
              updates_disabled = true;
            };

            "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
              install_url = moz "vimium-ff";
              installation_mode = "force_installed";
              updates_disabled = true;
            };

            "{849ee818-783e-44ec-b22d-c190c12964d3}" = {
              install_url = moz "todoist_sidebar";
              installation_mode = "force_installed";
              updates_disabled = true;
            };

            "uBlock0@raymondhill.net" = {
              install_url = moz "ublock-origin";
              installation_mode = "force_installed";
              updates_disabled = true;
            };
          };
      };
      profiles = {
        ${username} = {
          search = {
            force = true;
            default = "google";
            privateDefault = "ddg";
            order = [
              "ddg"
              "google"
            ];
            engines = {
              "bing".metaData.hidden = true;
              "ddg".metaData.alias = "@d";
              "google".metaData.alias = "@g";
              "wikipedia".metaData.alias = "@w";

              "archlinux" = {
                urls = [ { template = "https://wiki.archlinux.org/index.php?search={searchTerms}"; } ];
                icon = "https://wiki.archlinux.org/favicon.ico";
                definedAliases = [ "@a" ];
              };

              "github" = {
                urls = [ { template = "https://github.com/search?q={searchTerms}"; } ];
                icon = "https://github.githubassets.com/favicons/favicon.svg";
                definedAliases = [ "@gh" ];
              };

              "reddit" = {
                urls = [ { template = "https://reddit.com/search?q={searchTerms}"; } ];
                icon = "https://www.redditstatic.com/shreddit/assets/favicon/192x192.png";
                definedAliases = [ "@r" ];
              };

              "mynixos" = {
                urls = [ { template = "https://mynixos.com/search?q={searchTerms}"; } ];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@n" ];
              };

              "nixoswiki" = {
                urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
                icon = "https://wiki.nixos.org/nixos.png";
                definedAliases = [ "@nw" ];
              };

              "php" = {
                urls = [ { template = "https://php.net/{searchTerms}"; } ];
                icon = "https://www.php.net/favicon-196x196.png?v=2";
                definedAliases = [ "@php" ];
              };

              "protondb" = {
                urls = [ { template = "https://protondb.com/search?q={searchTerms}"; } ];
                icon = "https://protondb.com/sites/protondb/images/favicon-32x32.png";
                definedAliases = [ "@p" ];
              };

              "youtube" = {
                urls = [ { template = "https://youtube.com/results?search_query={searchTerms}"; } ];
                icon = "https://youtube.com/img/favicon_144.png";
                definedAliases = [ "@yt" ];
              };

              "youtubemusic" = {
                urls = [ { template = "https://music.youtube.com/search?q={searchTerms}"; } ];
                icon = "https://music.youtube.com/img/favicon_144.png";
                definedAliases = [ "@ytm" ];
              };

              "rottentomatoes" = {
                urls = [ { template = "https://www.rottentomatoes.com/search?search={searchTerms}"; } ];
                icon = "https://editorial.rottentomatoes.com/wp-content/uploads/2022/05/favicon.png?w=32";
                definedAliases = [ "@rt" ];
              };

              "sonarr" = {
                urls = [ { template = "https://sonarr.99linesofcode.nl/add/new?term={searchTerms}"; } ];
                icon = "https://sonarr.99linesofcode.nl/Content/Images/Icons/favicon-32x32.png";
                definedAliases = [ "@sonarr" ];
              };

              "radarr" = {
                urls = [ { template = "https://radarr.99linesofcode.nl/add/new?term={searchTerms}"; } ];
                icon = "https://radarr.99linesofcode.nl/Content/Images/Icons/favicon-32x32.png";
                definedAliases = [ "@radarr" ];
              };
            };
          };
          settings = {
            "browser.toolbars.bookmarks.visibility" = "never"; # bookmark bar vsibility (always, newtab, never)
            "extensions.autoDisableScopes" = 0; # automatically enable extensions
            "widget.use-xdg-desktop-portal" = true;

            # TODO: required for nvidia-vaapi-driver, how to toggle on nixos-config value 🤔
            "media.ffmpeg.vaapi.enabled" = true;
          };
        };
      };
    };

    xdg.mimeApps.defaultApplications = mkIf cfg.defaultApplication.enable (
      lib.genAttrs cfg.defaultApplication.mimeTypes (_: "firefox.desktop")
    );
  };
}
