{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.home.nvim;
in
  with lib; {
    imports = [
      inputs.nixvim.homeManagerModules.nixvim
      ./nvim/bufferline.nix
      ./nvim/cmp.nix
      ./nvim/conform.nix
      ./nvim/dap.nix
      ./nvim/lsp.nix
      ./nvim/mini.nix
      ./nvim/neo-tree.nix
      ./nvim/todo-comments.nix
      ./nvim/treesitter.nix
      ./nvim/telescope.nix
      ./nvim/trouble.nix
    ];

    options = {
      home.nvim.enable = mkEnableOption "nvim";
    };

    # TODO: write autocommand to open helpfiles in vertical split
    config = mkIf cfg.enable {
      programs = {
        fd.enable = true;
        fzf.enable = true;
        ripgrep.enable = true;
        nixvim = {
          enable = true;
          defaultEditor = true;
          viAlias = true;
          vimAlias = true;
          vimdiffAlias = true;
          globals.mapleader = " ";

          opts = {
            autowrite = true; # write the contents of the file automatically on certain commands
            clipboard = "unnamedplus"; # use system clipboard
            completeopt = "menu,menuone,noselect";
            confirm = true; # confirm to save changes before exiting modified buffer
            cursorline = true; # enable highlighting of the current line
            expandtab = true; # use spaces instead of tabs
            foldmethod = "expr"; # fold level of a line
            foldtext = "";
            formatoptions = "jcroqlnt"; # default: tcqj
            grepformat = "%f:%l:%c:%m";
            grepprg = "rg --vimgrep";
            ignorecase = true; # enable case insensitive search
            inccommand = "nosplit"; # show effects of a command incrementally in the buffer
            jumpoptions = "view";
            laststatus = 3; # global status line
            linebreak = true; # wrap lines at convenient points
            list = true; # show invisible characters
            listchars = "extends:›,nbsp:␣,precedes:‹,tab:»\ ,trail:·";
            mouse = "a"; # enable mouse mode
            number = true; # show line numbers
            relativenumber = true; # relative line numbers
            softtabstop = 2; # number of spaces that represent a <TAB>
            smartcase = true; # don't ignore case when using capital letters
            smartindent = true; # insert indents automatically
            spelllang = ["en" "nl"];
            shiftround = true; # round indent
            shiftwidth = 2; # size of indent
            showmode = false; # don't show mode as we are using a statusline
            smoothscroll = true;
            splitkeep = "screen"; # keep the text on the same line
            splitbelow = true; # put new windows below current
            splitright = true; # put new windows right of current
            tabstop = 2; # number of spaces tabs count for
            termguicolors = true; # true color support
            undofile = true;
            undolevels = 10000;
            updatetime = 200; # save swap file and trigger CursorHold
            virtualedit = "block"; # allow cursor to move where there is no text in visual block mode
            winminwidth = 5; # minim window width
            wrap = false; # disable line wrap
          };

          keymaps =
            [
              # save file
              {
                mode = ["i" "x" "n" "s"];
                key = "<C-s>";
                action = "<cmd>w<cr><esc>";
                options = {desc = "Save File";};
              }

              # quit all
              {
                mode = "n";
                key = "<leader>qq";
                action = "<cmd>qa<cr>";
                options = {desc = "Quit All";};
              }

              # better up/down
              {
                mode = ["n" "x"];
                key = "j";
                action = "v:count == 0 ? 'gj' : 'j'";
                options = {
                  expr = true;
                  silent = true;
                };
              }
              {
                mode = ["n" "x"];
                key = "<Down>";
                action = "v:count == 0 ? 'gj' : 'j'";
                options = {
                  expr = true;
                  silent = true;
                };
              }
              {
                mode = ["n" "x"];
                key = "k";
                action = "v:count == 0 ? 'gk' : 'k'";
                options = {
                  expr = true;
                  silent = true;
                };
              }
              {
                mode = ["n" "x"];
                key = "<Up>";
                action = "v:count == 0 ? 'gk' : 'k'";
                options = {
                  expr = true;
                  silent = true;
                };
              }

              # move to window using <ctrl> hjkl keys
              {
                mode = "n";
                key = "<C-h>";
                action = "<C-w>h";
                options = {
                  desc = "Go to Left Window";
                  remap = true;
                };
              }
              {
                mode = "n";
                key = "<C-j>";
                action = "<C-w>j";
                options = {
                  desc = "Go to Lower Window";
                  remap = true;
                };
              }
              {
                mode = "n";
                key = "<C-k>";
                action = "<C-w>k";
                options = {
                  desc = "Go to Upper Window";
                  remap = true;
                };
              }
              {
                mode = "n";
                key = "<C-l>";
                action = "<C-w>l";
                options = {
                  desc = "Go to Right Window";
                  remap = true;
                };
              }

              # resize window using the <ctrl> arrow keys
              {
                mode = "n";
                key = "<C-Up>";
                action = "<cmd>resize +2<cr>";
                options = {desc = "Increase Window Height";};
              }
              {
                mode = "n";
                key = "<C-Down>";
                action = "<cmd>resize -2<cr>";
                options = {desc = "Decrease Window Height";};
              }
              {
                mode = "n";
                key = "<C-Left>";
                action = "<cmd>vertical resize -2<cr>";
                options = {desc = "Decrease Window Width";};
              }
              {
                mode = "n";
                key = "<C-Right>";
                action = "<cmd>vertical resize +2<cr>";
                options = {desc = "Increase Window Width";};
              }

              # move lines around using the <alt> hjkl keys
              {
                mode = "n";
                key = "<A-j>";
                action = "<cmd>m .+1<cr>==";
                options = {desc = "Move Down";};
              }
              {
                mode = "n";
                key = "<A-k>";
                action = "<cmd>m .-2<cr>==";
                options = {desc = "Move Up";};
              }
              {
                mode = "i";
                key = "<A-j>";
                action = "<esc><cmd>m .+1<cr>==gi";
                options = {desc = "Move Down";};
              }
              {
                mode = "i";
                key = "<A-k>";
                action = "<esc><cmd>m .-2<cr>==gi";
                options = {desc = "Move Up";};
              }
              {
                mode = "v";
                key = "<A-j>";
                action = ":m '>+1<cr>gv=gv";
                options = {desc = "Move Down";};
              }
              {
                mode = "v";
                key = "<A-k>";
                action = ":m '<-2<cr>gv=gv";
                options = {desc = "Move Up";};
              }

              # buffers
              {
                mode = ["n"];
                key = "<S-h>";
                action = "<cmd>bprevious<cr>";
                options = {desc = "Prev Buffer";};
              }
              {
                mode = ["n"];
                key = "<leader>bb";
                action = "<cmd>e #<br>";
                options = {desc = "Switch to Other Buffer";};
              }
              {
                mode = "n";
                key = "<leader>bd";
                action = "<cmd>bdelete<cr>";
                options = {
                  desc = "Delete Buffer";
                };
              }

              # clear search with <esc>
              {
                mode = ["i" "n"];
                key = "<esc>";
                action = "<cmd>noh<cr><esc>";
                options = {desc = "Escape and Clear hlsearch";};
              }

              # clear search, diff update and redraw
              {
                mode = "n";
                key = "<leader>ur";
                action = "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>";
                options = {desc = "Redraw / Clear hlsearch / Diff Update";};
              }

              # https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
              {
                mode = "n";
                key = "n";
                action = "'Nn'[v:searchforward].'zv'";
                options = {
                  expr = true;
                  desc = "Next Search Result";
                };
              }
              {
                mode = "x";
                key = "n";
                action = "'Nn'[v:searchforward]";
                options = {
                  expr = true;
                  desc = "Next Search Result";
                };
              }
              {
                mode = "o";
                key = "n";
                action = "'Nn'[v:searchforward]";
                options = {
                  expr = true;
                  desc = "Next Search Result";
                };
              }
              {
                mode = "n";
                key = "N";
                action = "'nN'[v:searchforward].'zv'";
                options = {
                  expr = true;
                  desc = "Prev Search Result";
                };
              }
              {
                mode = "x";
                key = "N";
                action = "'nN'[v:searchforward]";
                options = {
                  expr = true;
                  desc = "Prev Search Result";
                };
              }
              {
                mode = "o";
                key = "N";
                action = "'nN'[v:searchforward]";
                options = {
                  expr = true;
                  desc = "Prev Search Result";
                };
              }

              # better indenting
              {
                mode = "v";
                key = "<";
                action = "<gv";
              }
              {
                mode = "v";
                key = ">";
                action = ">gv";
              }

              # diagnostics
              {
                mode = "n";
                key = "<leader>cd";
                action = "vim.diagnostic.open_float";
                options = {desc = "Line Diagnostics";};
              }
              {
                mode = "n";
                key = "]d";
                action = "diagnostic_goto(true)";
                options = {desc = "Next Diagnostic";};
              }
              {
                mode = "n";
                key = "[d";
                action = "diagnostic_goto(false)";
                options = {desc = "Prev Diagnostic";};
              }
              {
                mode = "n";
                key = "]e";
                action = "diagnostic_goto(true 'ERROR')";
                options = {desc = "Next Error";};
              }
              {
                mode = "n";
                key = "[e";
                action = "diagnostic_goto(false 'ERROR')";
                options = {desc = "Prev Error";};
              }
              {
                mode = "n";
                key = "]w";
                action = "diagnostic_goto(true 'WARN')";
                options = {desc = "Next Warning";};
              }
              {
                mode = "n";
                key = "[w";
                action = "diagnostic_goto(false 'WARN')";
                options = {desc = "Prev Warning";};
              }

              # commenting
              {
                mode = "n";
                key = "gco";
                action = "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>";
                options = {desc = "Add Comment Below";};
              }
              {
                mode = "n";
                key = "gcO";
                action = "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>";
                options = {desc = "Add Comment Above";};
              }

              # highlight under cursor
              {
                mode = "n";
                key = "<leader>ui";
                action = "vim.show_pos";
                options = {desc = "Inspect Pos";};
              }
              {
                mode = "n";
                key = "<leader>uI";
                action = "<cmd>InspectTree<cr>";
                options = {desc = "Inspect Tree";};
              }

              # terminal mappings
              {
                mode = "t";
                key = "<esc><esc>";
                action = "<c-\\><c-n>";
                options = {desc = "Enter Normal Mode";};
              }
              {
                mode = "t";
                key = "<C-h>";
                action = "<cmd>wincmd h<cr>";
                options = {desc = "Go to Left Window";};
              }
              {
                mode = "t";
                key = "<C-j>";
                action = "<cmd>wincmd j<cr>";
                options = {desc = "Go to Lower Window";};
              }
              {
                mode = "t";
                key = "<C-k>";
                action = "<cmd>wincmd k<cr>";
                options = {desc = "Go to Upper Window";};
              }
              {
                mode = "t";
                key = "<C-l>";
                action = "<cmd>wincmd l<cr>";
                options = {desc = "Go to Right Window";};
              }
              {
                mode = "t";
                key = "<C-/>";
                action = "<cmd>close<cr>";
                options = {desc = "Hide Terminal";};
              }

              # window management
              {
                mode = "n";
                key = "<leader>w";
                action = "<C-W>";
                options = {
                  desc = "Windows";
                  remap = true;
                };
              }
              {
                mode = "n";
                key = "<leader>-";
                action = "<C-W>s";
                options = {
                  desc = "Split Window Below";
                  remap = true;
                };
              }
              {
                mode = "n";
                key = "<leader>|";
                action = "<C-W>v";
                options = {
                  desc = "Split Window Right";
                  remap = true;
                };
              }
              {
                mode = "n";
                key = "<leader>wd";
                action = "<C-W>c";
                options = {
                  desc = "Delete Window";
                  remap = true;
                };
              }

              # tabs
              {
                mode = "n";
                key = "<leader><tab>l";
                action = "<cmd>tablast<cr>";
                options = {desc = "Last Tab";};
              }
              {
                mode = "n";
                key = "<leader><tab>f";
                action = "<cmd>tabfirst<cr>";
                options = {desc = "First Tab";};
              }
              {
                mode = "n";
                key = "<leader><tab><tab>";
                action = "<cmd>tabnew<cr>";
                options = {desc = "New Tab";};
              }
              {
                mode = "n";
                key = "<leader><tab>]";
                action = "<cmd>tabnext<cr>";
                options = {desc = "Next Tab";};
              }
              {
                mode = "n";
                key = "<leader><tab>d";
                action = "<cmd>tabclose<cr>";
                options = {desc = "Close Tab";};
              }
              {
                mode = "n";
                key = "<leader><tab>[";
                action = "<cmd>tabprevious<cr>";
                options = {desc = "Previous Tab";};
              }
            ]
            ++ optionals config.programs.lazygit.enable [
              # lazygit
              {
                mode = "n";
                key = "<leader>gg";
                action = "<cmd>LazyGit<cr>";
                options = {desc = "LazyGit (cwd)";};
              }
            ];

          plugins = {
            conform-nvim.enable = true; # formatting
            dashboard.enable = true;
            flash = {
              enable = true;
              settings.modes = {
                char.jump_labels = true;
                search.enabled = true;
              };
            };
            friendly-snippets.enable = true;
            gitsigns.enable = true;
            indent-blankline = {
              enable = true;
              settings = {
                exclude = {
                  filetypes = [
                    "help"
                    "alpha"
                    "dashboard"
                    "neo-tree"
                    "Trouble"
                    "trouble"
                    "notify"
                  ];
                };
                indent = {
                  char = "│";
                };
                scope = {
                  show_end = false;
                  show_start = true;
                };
              };
            };
            lazygit.enable = config.programs.lazygit.enable;
            lint.enable = true; # linting
            lualine.enable = true;
            noice.enable = true;
            notify = {
              enable = true;
              timeout = 1000;
            };
            schemastore.enable = true;
            ts-autotag.enable = true;
            ts-comments.enable = true;
            undotree.enable = true;
            web-devicons.enable = true;
            which-key.enable = true;
          };
        };
      };
    };
  }
