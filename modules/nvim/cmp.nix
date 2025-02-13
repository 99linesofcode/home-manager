{ ... }:
{
  programs.nixvim = {
    keymaps = [
    ];

    plugins = {
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          formatting.fields = [
            "kind"
            "abbr"
            "menu"
          ];
          mapping = {
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-j>" = "cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert })";
            "<C-k>" = "cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert })";
            "<C-Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<C-Space>" = "cmp.mapping.complete()";
            "<CR>" = "cmp.mapping.confirm({ select = auto_select })";
            "<C-y>" = "cmp.mapping.confirm({ select = true })";
            "<S-CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })"; # accept currently selected item
            "<C-CR>" = "cmp.mapping.abort()";
          };
          performance = {
            debounce = 60;
            fetchingTimeout = 200;
            maxViewEntries = 30;
          };
          snippet.expand = "luasnip";
          sources = [
            { name = "emoji"; }
            { name = "buffer"; }
            { name = "cmdline"; }
            { name = "dap"; }
            { name = "luasnip"; }
            { name = "nvim_lsp"; }
            { name = "path"; }
          ];
        };
      };
      cmp-nvim-lsp.enable = true;
    };
  };
}
