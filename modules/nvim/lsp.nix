{ ... }:
{
  programs.nixvim = {
    keymaps = [
    ];

    plugins = {
      lsp = {
        enable = true;
        inlayHints = true;
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
        servers = {
          # TODO: do we install these globally or in each devshell?
          bashls.enable = true;
          emmet_ls.enable = true;
          eslint.enable = true;
          html.enable = true;
          jsonls.enable = true;
          lua_ls.enable = true;
          marksman.enable = true;
          nil_ls.enable = true;
          pest_ls.enable = true;
          phpactor.enable = true;
          pyright.enable = true;
          ruby_lsp.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
          tailwindcss.enable = true;
          ts_ls.enable = true;
          volar.enable = true;
          yamlls.enable = true;
        };
      };
      lsp-format.enable = true; # formatting
      lspkind.enable = true; # vscode-like pictograms for lsp
      lsp-signature.enable = true; # method signatures
    };
  };
}
