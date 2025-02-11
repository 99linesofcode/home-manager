{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}: let
  inherit (specialArgs) username;
  cfg = config.host.firefox;
in
  with lib; {
    options = {
      host.firefox.enable = mkEnableOption "firefox";
    };

    config = mkIf cfg.enable {
      programs.firefox = {
        enable = true;
        package = pkgs.wrapFirefox (pkgs.firefox-unwrapped.override {
          pipewireSupport = true;
        }) {};
        profiles = {
          ${username} = {
            search = {
              force = true;
              default = "Google";
              privateDefault = "DuckDuckGo";
              order = ["Google" "DuckDuckGo"];
              engines = {
                "Bing".metaData.hidden = true;
                "DuckDuckGo".metaData.alias = "@d";
                "Google".metaData.alias = "@g";
                "Wikipedia (en)".metaData.alias = "@w";

                "Github" = {
                  urls = [{template = "https://github.com/search?q={searchTerms}";}];
                  iconUpdateURL = "https://github.githubassets.com/favicons/favicon.svg";
                  definedAliases = ["@gh"];
                };

                "Reddit" = {
                  urls = [{template = "https://reddit.com/search?q={searchTerms}";}];
                  iconUpdateURL = "https://www.redditstatic.com/shreddit/assets/favicon/192x192.png";
                  definedAliases = ["@r"];
                };

                "MyNixOS" = {
                  urls = [{template = "https://mynixos.com/search?q={searchTerms}";}];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = ["@n"];
                };

                "NixOS Wiki" = {
                  urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
                  iconUpdateURL = "https://wiki.nixos.org/favicon.png";
                  definedAliases = ["@nw"];
                };

                "ProtonDB" = {
                  urls = [{template = "https://protondb.com/search?q={searchTerms}";}];
                  iconUpdateURL = "https://protondb.com/sites/protondb/images/favicon-32x32.png";
                  definedAliases = ["@p"];
                };

                "YouTube" = {
                  urls = [{template = "https://youtube.com/results?search_query={searchTerms}";}];
                  iconUpdateURL = "https://youtube.com/img/favicon_144.png";
                  definedAliases = ["@yt"];
                };

                "YouTube Music" = {
                  urls = [{template = "https://music.youtube.com/search?q={searchTerms}";}];
                  iconUpdateURL = "https://music.youtube.com/img/favicon_144.png";
                  definedAliases = ["@ytm"];
                };
              };
            };
            settings = {
              "widget.use-xdg-desktop-portal.file-picker" = 1;
            };
          };
        };
      };
    };
  }
