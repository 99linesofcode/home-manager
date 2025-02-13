{ ... }:
{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>sd";
        action = "<cmd>Telescope diagnostics bufnr=0<cr>";
        options = {
          desc = "Document diagnostics";
        };
      }
      {
        mode = "n";
        key = "<leader>fe";
        action = "<cmd>Telescope file_browser<cr>";
        options = {
          desc = "File browser";
        };
      }
      {
        mode = "n";
        key = "<leader>fE";
        action = "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>";
        options = {
          desc = "File browser";
        };
      }
    ];

    plugins = {
      telescope = {
        enable = true;
        extensions = {
          file-browser.enable = true;
          fzf-native.enable = true;
        };
        settings = {
          defaults = {
            sorting_strategy = "ascending";
          };
        };
        keymaps = {
          "<leader>/" = {
            action = "live_grep";
            options = {
              desc = "Grep (Root Dir)";
            };
          };
          "<leader>:" = {
            action = "command_history";
            options = {
              desc = "Command History";
            };
          };

          # find
          "<leader><space>" = {
            action = "find_files";
            options = {
              desc = "Find Files";
            };
          };
          "<leader>b" = {
            action = "buffers";
            options = {
              desc = "buffers sort_mru=true sort_lastused=true";
            };
          };
          "<leader>fg" = {
            action = "oldfiles";
            options = {
              desc = "File Files (git-files)";
            };
          };
          "<leader>fr" = {
            action = "<cmd>Telescope oldfiles<cr>";
            options = {
              desc = "Recent";
            };
          };

          # git
          "<leader>gc" = {
            action = "git_commits";
            options = {
              desc = "Commits";
            };
          };
          "<leader>gs" = {
            action = "git_status";
            options = {
              desc = "Status";
            };
          };

          # search
          "<leader>s\"" = {
            action = "registers";
            options = {
              desc = "Registers";
            };
          };
          "<leader>sa" = {
            action = "autocommands";
            options = {
              desc = "Auto Commands";
            };
          };
          "<leader>sb" = {
            action = "current_buffer_fuzzy_find";
            options = {
              desc = "Buffer";
            };
          };
          "<leader>sc" = {
            action = "command_history";
            options = {
              desc = "Command History";
            };
          };
          "<leader>sC" = {
            action = "commands";
            options = {
              desc = "Commands";
            };
          };
          "<leader>sd" = {
            action = "diagnostics bufnr=0";
            options = {
              desc = "Document Diagnostics";
            };
          };
          "<leader>sD" = {
            action = "diagnostics";
            options = {
              desc = "Workspace Diagnostics";
            };
          };
          "<leader>sh" = {
            action = "help_tags";
            options = {
              desc = "Help Pages";
            };
          };
          "<leader>sH" = {
            action = "highlights";
            options = {
              desc = "Search Highlight Groups";
            };
          };
          "<leader>sj" = {
            action = "jumplist";
            options = {
              desc = "Jumplist";
            };
          };
          "<leader>sk" = {
            action = "keymaps";
            options = {
              desc = "Keymaps";
            };
          };
          "<leader>sl" = {
            action = "loclist";
            options = {
              desc = "Location List";
            };
          };
          "<leader>sM" = {
            action = "man_pages";
            options = {
              desc = "Man pages";
            };
          };
          "<leader>sm" = {
            action = "marks";
            options = {
              desc = "Jump to Mark";
            };
          };
          "<leader>so" = {
            action = "vim_options";
            options = {
              desc = "Options";
            };
          };
          "<leader>sR" = {
            action = "resume";
            options = {
              desc = "Resume";
            };
          };
          "<leader>sq" = {
            action = "quickfix";
            options = {
              desc = "Quickfix List";
            };
          };
          "<leader>uC" = {
            action = "colorscheme";
            options = {
              desc = "Colorscheme preview";
            };
          };
        };
      };
    };
  };
}
