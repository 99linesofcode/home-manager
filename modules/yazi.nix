{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.yazi;
  uwsmPrefix = config.home.wayland.uwsm.prefix;
in
with lib;
{
  options = {
    home.yazi.enable = mkEnableOption "yazi";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ueberzugpp
    ];

    programs.yazi = {
      enable = true;
      settings = {
        manager = {
          linemode = "none";
          ratio = [
            1
            4
            3
          ];
          sort_by = "natural";
          sort_sensitive = true;
          sort_reverse = false;
          sort_dir_first = true;
          sort_translit = true;
          show_hidden = true;
          show_symlink = true;
        };

        preview = {
          image_filter = "triangle";
          image_quality = 90;
          max_width = 600;
          max_height = 900;
          tab_size = 1;
          ueberzug_scale = 1;
          ueberzug_offset = [
            0
            0
            0
            0
          ];
        };

        tasks = {
          bizarre_retry = 5;
          macro_workers = 10;
          micro_workers = 5;
        };
      };
      plugins = {
        # TODO: add ouch.yazi for compressing and decompressing archives
      };
    };

    wayland.windowManager.hyprland.settings = mkIf config.home.hyprland.enable {
      bind = [
        "SUPER, E, exec, ${uwsmPrefix}alacritty -e 'yazi'"
      ];
    };
  };
}
