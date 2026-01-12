{ ... }:
{
  programs.nixvim = {
    keymaps = [
    ];

    plugins = {
      treesitter = {
        enable = true;
        folding.enable = true;
        highlight.enable = true;
        indent.enable = true;
        nixvimInjections = true;
      };
      treesitter-context = {
        enable = true;
        settings = {
          max_lines = 1;
          trim_scope = "outer";
        };
      };
      # treesitter-refactor.enable = true; # FIXME: wouldnt build for 4ebc11dad54b7e5b8a46c6edb2533852e99ec566bbe10836b2d6dba89c9c2e3c
      treesitter-textobjects = {
        enable = true;
        settings = {
          select = {
            enable = true;
            lookahead = true;
            keymaps = {
              "aa" = "@parameter.outer";
              "ia" = "@parameter.inner";
              "af" = "@function.outer";
              "if" = "@function.inner";
              "ac" = "@class.outer";
              "ic" = "@class.inner";
              "ii" = "@conditional.inner";
              "ai" = "@conditional.outer";
              "il" = "@loop.inner";
              "al" = "@loop.outer";
              "at" = "@comment.outer";
            };
          };
          move = {
            enable = true;
            goto_next_start = {
              "]m" = "@function.outer";
              "]]" = "@class.outer";
            };
            goto_next_end = {
              "]M" = "@function.outer";
              "][" = "@class.outer";
            };
            goto_previous_start = {
              "[m" = "@function.outer";
              "[[" = "@class.outer";
            };
            goto_previous_end = {
              "[M" = "@function.outer";
              "[]" = "@class.outer";
            };
          };
          swap = {
            enable = true;
            swap_next = {
              "<leader>a" = "@parameters.inner";
            };
            swap_previous = {
              "<leader>A" = "@parameter.outer";
            };
          };
        };
      };
    };
  };
}
