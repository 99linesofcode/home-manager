{ ... }:
{
  programs.nixvim = {
    keymaps = [
      {
        mode = [ "n" ];
        key = "<leader>e";
        action = "<cmd>Neotree toggle<cr>";
        options = {
          desc = "Open/Close Neotree";
        };
      }
    ];

    plugins.neo-tree = {
      enable = true;
      settings = {
        closeIfLastWindow = true;
        defaultComponentConfigs = {
          indent = {
            withExpanders = true;
            expanderCollapsed = "󰅂";
            expanderExpanded = "󰅀";
            expanderHighlight = "NeoTreeExpander";
          };

          gitStatus = {
            symbols = {
              added = " ";
              conflict = "󰩌 ";
              deleted = "󱂥";
              ignored = " ";
              modified = " ";
              renamed = "󰑕";
              staged = "󰩍";
              unstaged = "";
              untracked = " ";
            };
          };
        };
        filesystem = {
          bindToCwd = false;
          follow_current_file = {
            enabled = true;
          };
          filtered_items = {
            hide_dotfiles = false;
            hide_gitignored = false;
          };
        };
        sources = [
          "filesystem"
          "buffers"
          "git_status"
          "document_symbols"
        ];
        window.position = "right";
      };
    };
  };
}
