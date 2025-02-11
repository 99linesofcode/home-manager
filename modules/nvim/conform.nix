{
  lib,
  pkgs,
  ...
}: {
  programs.nixvim = {
    keymaps = [
    ];

    plugins.conform-nvim = {
      enable = true;
      settings = {
        format_on_save = ''
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

        format_after_save = ''
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
          css = [
            "stylelint"
          ];
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
          json = [
            "jq"
          ];
          lua = [
            "stylua"
          ];
          markdown = [
            "markdownfmt"
          ];
          nix = [
            "alejandra"
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

        formatters = {
          alejandra = {
            command = "${lib.getExe pkgs.alejandra}";
          };
          black = {
            command = "${lib.getExe pkgs.black}";
          };
          eslint_d = {
            command = "${lib.getExe pkgs.eslint_d}";
          };
          isort = {
            command = "${lib.getExe pkgs.isort}";
          };
          jq = {
            command = "${lib.getExe pkgs.jq}";
          };
          prettierd = {
            command = "${lib.getExe pkgs.prettierd}";
          };
          php_cs_fixer = {
            command = "${lib.getExe pkgs.php83Packages.php-cs-fixer}";
          };
          shellcheck = {
            command = "${lib.getExe pkgs.shellcheck}";
          };
          shellharden = {
            command = "${lib.getExe pkgs.shellharden}";
          };
          shfmt = {
            command = "${lib.getExe pkgs.shfmt}";
          };
          stylua = {
            command = "${lib.getExe pkgs.stylua}";
          };
        };

        notify_on_error = true;
      };
    };
  };
}
