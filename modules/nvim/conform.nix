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
        format_on_save.__raw = ''
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

        format_after_save.__raw = ''
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
            "shellcheck"
            "shellharden"
            "shfmt"
          ];
          bash = [
            "shellcheck"
            "shellharden"
            "shfmt"
          ];
          blade = [
            "superhtml"
            "blade-formatter"
            "eslint_d"
            "prettierd"
            "prettier"
          ];
          c = [
            "clang-format"
          ];
          css = [
            "stylelint"
            "eslint_d"
            "prettierd"
            "prettier"
          ];
          html = [
            "superhtml"
            "eslint_d"
            "prettierd"
            "prettier"
          ];
          javascript = [
            "eslint_d"
            "prettierd"
            "prettier"
          ];
          javascriptreact = [
            "eslint_d"
            "prettierd"
            "prettier"
          ];
          json = [
            "jq"
            "eslint_d"
            "prettierd"
            "prettier"
          ];
          lua = [
            "stylua"
          ];
          markdown = [
            "markdownlint-cli2"
            "eslint_d"
            "prettierd"
            "prettier"
          ];
          nix = [
            "nixfmt-rfc-style"
          ];
          php = [
            "pint"
            "php_cs_fixer"
          ];
          python = [
            "black"
            "isort"
          ];
          rust = [
            "rustfmt"
          ];
          typescript = [
            "eslint_d"
            "prettierd"
            "prettier"
          ];
          typescriptreact = [
            "eslint_d"
            "prettierd"
            "prettier"
          ];
          yaml = [
            "yq"
            "eslint_d"
            "prettierd"
            "prettier"
          ];
        };

        formatters = with pkgs; {
          isort = {
            command = lib.getExe isort;
          };
          jq = {
            command = lib.getExe jq;
          };
          nixfmt-rfc-style = {
            command = lib.getExe nixfmt-rfc-style;
          };
          shellcheck = {
            command = lib.getExe shellcheck;
          };
          shellharden = {
            command = lib.getExe shellharden;
          };
          shfmt = {
            command = lib.getExe shfmt;
          };
          stylua = {
            command = lib.getExe stylua;
          };
          squeeze_blanks = {
            command = lib.getExe' pkgs.coreutils "cat";
          };
          yq = {
            command = lib.getExe yq;
          };
        };
      };
    };
  };
}
