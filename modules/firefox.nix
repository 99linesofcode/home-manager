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
    programs.firefox = {
      enable = true;
      languagePacks = [
        "en-US"
        "en-GB"
        "nl"
      ];
      package = pkgs.wrapFirefox (pkgs.firefox-unwrapped.override {
        pipewireSupport = true;
      }) { };
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DNSOverHTTPS = {
          Enabled = true;
          ProviderUrl = "dns.quad9.net";
          Locked = true;
          Fallback = true;
        };
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          EmailTracking = true;
          Fingerprinting = true;
        };
        NetworkPrediction = false; # DNS prefetching
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
        PostQuantumKeyAgreementEnabled = true;
      };
      profiles = {
        ${username} = {
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            bitwarden
            darkreader
            # fake-filler # TODO: added in a later commit
            gaoptout
            ublock-origin
            sponsorblock
            read-aloud # TTS
            return-youtube-dislikes
            vue-js-devtools
            vimium

            # TODO: package and contribute these to the NUR?
            # todoist sidebar
          ];
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

            # completely disable Pocket
            "extensions.pocket.enabled" = false;
            "extensions.pocket.api" = "0.0.0.0";
            "extensions.pocket.loggedOutVariant" = "";
            "extensions.pocket.oAuthConsumerKey" = "";
            "extensions.pocket.onSaveRecs" = false;
            "extensions.pocket.onSaveRecs.locales" = "";
            "extensions.pocket.showHome" = false;
            "extensions.pocket.site" = "0.0.0.0";
            "browser.newtabpage.activity-stream.pocketCta" = "";
            "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
            "services.sync.prefs.sync.browser.newtabpage.activity-stream.section.highlights.includePocket" =
              false;
          };
        };
      };
    };

    xdg.mimeApps.defaultApplications = mkIf cfg.defaultApplication.enable (
      lib.genAttrs cfg.defaultApplication.mimeTypes (_: "firefox.desktop")
    );
  };
}
