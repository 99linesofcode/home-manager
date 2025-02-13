{
  lib,
  pkgs,
  ...
}:
with lib;
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
            "trim_whitespace"
          ];
          bash = [
            "shellcheck"
            # "shellharden"
            # "shfmt"
          ];
          css = {
            __unkeyed-1 = "stylelint";
            __unkeyed-2 = "eslint_d";
            stop_after_first = true;
          };
          html = {
            __unkeyed-1 = "superhtml";
            __unkeyed-2 = "eslint_d";
            __unkeyed-3 = "prettierd";
            __unkeyed-4 = "prettier";
            stop_after_first = true;
          };
          javascript = {
            __unkeyed-1 = "eslint_d";
            __unkeyed-2 = "prettierd";
            __unkeyed-3 = "prettier";
            stop_after_first = true;
          };
          json = {
            __unkeyed-1 = "jq";
            __unkeyed-2 = "eslint_d";
            stop_after_first = true;
          };
          lua = [
            "stylua"
          ];
          markdown = {
            __unkeyed-1 = "markdownfmt";
            __unkeyed-2 = "eslint_d";
            stop_after_first = true;
          };
          nix = [
            "nixfmt-rfc-style"
          ];
          php = {
            __unkeyed-1 = "pint";
            __unkeyed-2 = "php_cs_fixer";
            stop_after_first = true;
          };
          python = [
            "black"
            # "isort"
          ];
          typescript = {
            __unkeyed-1 = "eslint_d";
            __unkeyed-2 = "prettierd";
            stop_after_first = true;
          };
          yaml = {
            __unkeyed-1 = "eslint_d";
            __unkeyed-2 = "prettierd";
            stop_after_first = true;
          };
        };

        formatters = with pkgs; {
          nixfmt-rfc-style = {
            command = "${getExe nixfmt-rfc-style}";
          };
          black = {
            command = "${getExe black}";
          };
          eslint_d = {
            command = "${getExe eslint_d}";
          };
          isort = {
            command = "${getExe isort}";
          };
          jq = {
            command = "${getExe jq}";
          };
          prettierd = {
            command = "${getExe prettierd}";
          };
          php_cs_fixer = {
            command = "${getExe php83Packages.php-cs-fixer}";
          };
          shellcheck = {
            command = "${getExe shellcheck}";
          };
          shellharden = {
            command = "${getExe shellharden}";
          };
          shfmt = {
            command = "${getExe shfmt}";
          };
          stylua = {
            command = "${getExe stylua}";
          };
        };

        notify_on_error = true;
      };
    };
  };
}
