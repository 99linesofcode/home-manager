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
  options = {
    home.firefox.enable = mkEnableOption "firefox";
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
            gaoptout # Google Analytics opt out
            ublock-origin
            sponsorblock
            read-aloud # TTS
            return-youtube-dislikes
            vimium

            # TODO: package and contribute these to the NUR?
            # clockify
            # todoist sidebar
          ];
          search = {
            force = true;
            default = "Google";
            privateDefault = "DuckDuckGo";
            order = [
              "Google"
              "DuckDuckGo"
            ];
            engines = {
              "Bing".metaData.hidden = true;
              "DuckDuckGo".metaData.alias = "@d";
              "Google".metaData.alias = "@g";
              "Wikipedia (en)".metaData.alias = "@w";

              "Github" = {
                urls = [ { template = "https://github.com/search?q={searchTerms}"; } ];
                iconUpdateURL = "https://github.githubassets.com/favicons/favicon.svg";
                definedAliases = [ "@gh" ];
              };

              "Reddit" = {
                urls = [ { template = "https://reddit.com/search?q={searchTerms}"; } ];
                iconUpdateURL = "https://www.redditstatic.com/shreddit/assets/favicon/192x192.png";
                definedAliases = [ "@r" ];
              };

              "MyNixOS" = {
                urls = [ { template = "https://mynixos.com/search?q={searchTerms}"; } ];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@n" ];
              };

              "NixOS Wiki" = {
                urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
                iconUpdateURL = "https://wiki.nixos.org/favicon.png";
                definedAliases = [ "@nw" ];
              };

              "PHP.net" = {
                urls = [ { template = "https://php.net/{searchTerms}"; } ];
                iconUpdateURL = "https://www.php.net/favicon-196x196.png?v=2";
                definedAliases = [ "@php" ];
              };

              "ProtonDB" = {
                urls = [ { template = "https://protondb.com/search?q={searchTerms}"; } ];
                iconUpdateURL = "https://protondb.com/sites/protondb/images/favicon-32x32.png";
                definedAliases = [ "@p" ];
              };

              "YouTube" = {
                urls = [ { template = "https://youtube.com/results?search_query={searchTerms}"; } ];
                iconUpdateURL = "https://youtube.com/img/favicon_144.png";
                definedAliases = [ "@yt" ];
              };

              "YouTube Music" = {
                urls = [ { template = "https://music.youtube.com/search?q={searchTerms}"; } ];
                iconUpdateURL = "https://music.youtube.com/img/favicon_144.png";
                definedAliases = [ "@ytm" ];
              };

              "Rotten Tomatoes" = {
                urls = [ { template = "https://www.rottentomatoes.com/search?search={searchTerms}"; } ];
                iconUpdateURL = "https://editorial.rottentomatoes.com/wp-content/uploads/2022/05/favicon.png?w=32";
                definedAliases = [ "@rt" ];
              };
            };
          };
          settings = {
            "widget.use-xdg-desktop-portal" = true;
          };
        };
      };
    };
  };
}
