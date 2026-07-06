{
  config,
  inputs,
  lib,
  pkgs,
  specialArgs,
  ...
}:
let
  inherit (specialArgs) username;
  cfg = config.home.stylix;
in
with lib;
{
  imports = [
    inputs.stylix.homeModules.stylix
  ];

  options = {
    home.stylix.enable = mkEnableOption "stylix";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      nerd-fonts.noto
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
          package = pkgs.nerd-fonts.noto;
        };
        sansSerif = {
          name = "NotoSans Nerd Font Propo";
          package = pkgs.nerd-fonts.noto;
        };
        monospace = {
          name = "NotoMono Nerd Font Propo";
          package = pkgs.nerd-fonts.noto;
        };
        emoji = {
          name = "Noto Color Emoji";
          package = pkgs.noto-fonts-color-emoji;
        };
      };
      icons = {
        enable = true;
        package = pkgs.papirus-icon-theme;
        dark = "Papirus Dark";
        light = "Papirus Light";
      };
      image = ../dotfiles/firewatch-green-1.jpg;
      polarity = "dark";
      targets = {
        firefox.profileNames = [ "${username}" ];
        # TODO: evaluate whether I want to enable this at some point
        hyprland.enable = false;
        vscode.profileNames = [ "default" ];
        waybar.font = "sansSerif";
      };
    };
  };
}
