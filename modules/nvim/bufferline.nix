{ ... }:
{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>bp";
        action = "<cmd>BufferLineTogglePin<cr>";
        options = {
          desc = "Toggle Pin";
        };
      }
      {
        mode = "n";
        key = "<leader>bP";
        action = "<Cmd>BufferLineGroupClose ungrouped<CR>";
        options = {
          desc = "Delete Non-Pinned Buffers";
        };
      }
      {
        mode = "n";
        key = "<leader>bo";
        action = "<cmd>BufferLineCloseOthers<cr>";
        options = {
          desc = "Delete Other Buffers";
        };
      }
      {
        mode = "n";
        key = "<leader>br";
        action = "<cmd>BufferLineCloseRight<cr>";
        options = {
          desc = "Delete Buffers to the Right";
        };
      }
      {
        mode = "n";
        key = "<leader>bl";
        action = "<cmd>BufferLineCloseLeft<cr>";
        options = {
          desc = "Delete Buffers to the Left";
        };
      }
      {
        mode = "n";
        key = "<S-h>";
        action = "<cmd>BufferLineCyclePrev<cr>";
        options = {
          desc = "Prev Buffer";
        };
      }
      {
        mode = "n";
        key = "<S-l>";
        action = "<cmd>BufferLineCycleNext<cr>";
        options = {
          desc = "Next Buffer";
        };
      }
      {
        mode = "n";
        key = "[b";
        action = "<cmd>BufferLineMovePrev<cr>";
        options = {
          desc = "Move Buffer Left";
        };
      }
      {
        mode = "n";
        key = "]b";
        action = "<cmd>BufferLineMoveNext<cr>";
        options = {
          desc = "Move Buffer Right";
        };
      }
    ];

    plugins.bufferline = {
      enable = true;
      settings = {
        options = {
          diagnostics = "nvim_lsp";
          mode = "buffers";
          offsets = [
            {
              filetype = "neo-tree";
              text = "Neo-tree";
              highlight = "Directory";
              text_align = "left";
            }
          ];
        };
      };
    };
  };
}
