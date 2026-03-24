{
  lib,
  pkgs,
  ...
}:
{
  programs.nixvim = {
    keymaps = [
    ];

    plugins.conform-nvim = {
      enable = true;
      settings = {
        format_on_save.__raw = # lua
          ''
            function(bufnr)
              if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                return
              end
              local function on_format(err)
                if err and err:match("timeout$") then
                  slow_format_filetypes[vim.bo[bufnr].filetype] = true
                end
              end

              return { lsp_fallback = true }, on_format
             end
          '';

        format_after_save.__raw = # lua
          ''
            function(bufnr)
              if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                return
              end

              return { lsp_fallback = true }
            end
          '';

        formatters_by_ft = {
          "_" = [
            "squeeze_blanks"
            "trim_whitespace"
            "trim_newlines"
          ];
          sh = [
            "shfmt"
          ];
          bash = [
            "shellharden"
            "shfmt"
          ];
          blade = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            __unkeyed-3 = "eslint_d";
            __unkeyed-4 = "blade-formatter";
            __unkeyed-5 = "superhtml";
            stop_after_first = true;
          };
          c = [
            "clang-format"
          ];
          css = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            __unkeyed-3 = "eslint_d";
            __unkeyed-4 = "stylelint";
            stop_after_first = true;
          };
          html = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            __unkeyed-3 = "eslint_d";
            __unkeyed-4 = "superhtml";
            stop_after_first = true;
          };
          javascript = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            __unkeyed-3 = "eslint_d";
            stop_after_first = true;
          };
          javascriptreact = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            __unkeyed-3 = "eslint_d";
            stop_after_first = true;
          };
          json = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            __unkeyed-3 = "eslint_d";
            __unkeyed-4 = "jq";
            stop_after_first = true;
          };
          lua = [
            "stylua"
          ];
          markdown = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            __unkeyed-3 = "eslint_d";
            __unkeyed-4 = "markdownlint-cli2";
            stop_after_first = true;
          };
          nix = [
            "nixfmt"
          ];
          php = {
            __unkeyed-1 = "pint";
            __unkeyed-2 = "php_cs_fixer";
            stop_after_first = true;
          };
          python = [
            "ruff_format"
          ];
          ruby = [
            "rubocop"
          ];
          rust = [
            "rustfmt"
          ];
          sql = [
            "sqruff"
          ];
          typescript = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            __unkeyed-3 = "eslint_d";
            stop_after_first = true;
          };
          typescriptreact = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            __unkeyed-3 = "eslint_d";
            stop_after_first = true;
          };
          yaml = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            __unkeyed-3 = "eslint_d";
            __unkeyed-4 = "yq";
            stop_after_first = true;
          };
        };

        formatters = with pkgs; {
          squeeze_blanks = {
            command = lib.getExe' pkgs.coreutils "cat";
          };
          yq = {
            command = lib.getExe yq-go;
          };
        };
      };
    };
  };
}
