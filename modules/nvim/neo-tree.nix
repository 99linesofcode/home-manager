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
        followCurrentFile = {
          enabled = true;
        };
        filteredItems = {
          hideDotfiles = false;
          hideGitignored = false;
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
}
