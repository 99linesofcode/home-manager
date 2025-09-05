{ config, lib, ... }:
with lib;
{
  programs.nixvim = {
    keymaps =
      [
        {
          mode = "n";
          key = "<leader>bd";
          action.__raw = ''
            function() Snacks.bufdelete() end
          '';
          options = {
            desc = "Delete Buffer";
          };
        }
        {
          mode = "n";
          key = "<leader>bo";
          action.__raw = ''
            function() Snacks.bufdelete.other() end
          '';
          options = {
            desc = "Delete Other Buffers";
          };
        }
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
          indent = {
            enabled = true;
            only_scope = true;
          };
          notifier = {
            enabled = true;
            timeout = 2000;
          };
          scroll.enabled = true;
          statuscolumn.enabled = true;
        };
      };
    };
  };
}
