{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.home.stylix;
in
  with lib; {
    imports = [
      inputs.stylix.homeManagerModules.stylix
    ];

    options = {
      home.stylix.enable = mkEnableOption "stylix";
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        (nerdfonts.override {
          fonts = [
            "Noto"
          ];
        })
        noto-fonts
        noto-fonts-emoji
      ];

      stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        cursor = {
          name = "Bibata-Modern-Ice";
          package = pkgs.bibata-cursors;
          size = 24;
        };
        fonts = {
          serif = {
            name = "NotoSerif Nerd Font Propo";
            package = pkgs.noto-fonts;
          };
          sansSerif = {
            name = "NotoSans Nerd Font Propo";
            package = pkgs.noto-fonts;
          };
          monospace = {
            name = "NotoMono Nerd Font Propo";
            package = pkgs.noto-fonts;
          };
          emoji = {
            name = "Noto Color Emoji";
            package = pkgs.noto-fonts-emoji;
          };
        };
        iconTheme = {
          enable = true;
          package = pkgs.papirus-icon-theme;
          dark = "Papirus Dark";
          light = "Papirus Light";
        };
        image = ../dotfiles/firewatch-green-1.jpg;
        polarity = "dark";
        targets = {
          # TODO: evaluate whether I want to enable this at some point
          hyprland.enable = false;
        };
      };
    };
  }
