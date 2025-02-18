{ config, lib, ... }:
with lib;
{
  programs.nixvim = {
    keymaps =
      [
      ]
      ++ optionals config.programs.lazygit.enable [
        {
          mode = "n";
          key = "<leader>gg";
          action.__raw = ''
            function() Snacks.lazygit() end
          '';
          options = {
            desc = "LazyGit";
          };
        }
      ];

    plugins = {
      snacks = {
        enable = true;
        settings = {
          dashboard.enabled = true;
          indent.enabled = true;
          notifier = {
            enabled = true;
            timeout = 1000;
          };
          scroll.enabled = true;
          statuscolumn.enabled = true;
        };
      };
    };
  };
}
