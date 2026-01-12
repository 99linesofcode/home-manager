{ pkgs, ... }:
{
  programs.nixvim = {
    keymaps = [
    ];

    plugins = {
      lsp = {
        enable = true;
        inlayHints = true;
        servers = {
          bashls.enable = true;
          emmet_ls.enable = true;
          eslint.enable = true;
          helm_ls.enable = true;
          html.enable = true;
          intelephense = {
            enable = true;
            package = pkgs.intelephense;
          };
          jsonls.enable = true;
          lua_ls.enable = true;
          marksman.enable = true;
          nil_ls.enable = true;
          pest_ls.enable = true;
          pyright.enable = true;
          ruby_lsp.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
          superhtml.enable = true;
          tailwindcss.enable = true;
          ts_ls.enable = true;
          vue_ls.enable = true;
          yamlls.enable = true;
        };

        keymaps = {
          silent = true;
          lspBuf = {
            gd = {
              action = "definition";
              desc = "Goto Definition";
            };
            gr = {
              action = "references";
              desc = "Goto References";
            };
            gD = {
              action = "declaration";
              desc = "Goto Declaration";
            };
            gI = {
              action = "implementation";
              desc = "Goto Implementation";
            };
            gT = {
              action = "type_definition";
              desc = "Type Definition";
            };
            K = {
              action = "hover";
              desc = "Hover";
            };
            "<leader>cw" = {
              action = "workspace_symbol";
              desc = "Workspace Symbol";
            };
            "<leader>cr" = {
              action = "rename";
              desc = "Rename";
            };
          };
          diagnostic = {
            "<leader>cd" = {
              action = "open_float";
              desc = "Line Diagnostics";
            };
            "[d" = {
              action = "goto_next";
              desc = "Next Diagnostic";
            };
            "]d" = {
              action = "goto_prev";
              desc = "Previous Diagnostic";
            };
          };
        };
      };
      lspkind.enable = true; # vscode-like pictograms for lsp
      lsp-signature.enable = true; # method signatures
    };
  };
}
