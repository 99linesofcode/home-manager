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

            return { timeout_ms = 200, lsp_fallback = true }, on_format
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
          bash = [
            "shellcheck"
            "shellharden"
            "shfmt"
          ];
          css = [
            "stylelint"
            "prettierd"
            "prettier"
          ];
          html = [
            "prettierd"
            "prettier"
          ];
          javascript = [
            "prettierd"
            "prettier"
          ];
          json = [
            "jq"
            "prettierd"
            "prettier"
          ];
          lua = [
            "stylua"
          ];
          markdown = [
            "prettierd"
            "prettier"
          ];
          nix = [
            "nixfmt-rfc-style"
          ];
          php = [
            "pint"
            "php_cs_fixer" # laravel/pint is built ontop of php_cs_fixer
          ];
          python = [
            "black"
            "isort"
          ];
          typescript = [
            "prettierd"
            "prettier"
          ];
          yaml = [
            "yq"
            "prettierd"
            "prettier"
          ];
        };

        formatters = with pkgs; {
          black = {
            command = lib.getExe black;
          };
          isort = {
            command = lib.getExe isort;
          };
          jq = {
            command = lib.getExe jq;
          };
          nixfmt-rfc-style = {
            command = lib.getExe nixfmt-rfc-style;
          };
          php_cs_fixer = {
            command = lib.getExe phpPackages.php-cs-fixer;
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
