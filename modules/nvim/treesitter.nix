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
            gotoNextStart = {
              "]m" = "@function.outer";
              "]]" = "@class.outer";
            };
            gotoNextEnd = {
              "]M" = "@function.outer";
              "][" = "@class.outer";
            };
            gotoPreviousStart = {
              "[m" = "@function.outer";
              "[[" = "@class.outer";
            };
            gotoPreviousEnd = {
              "[M" = "@function.outer";
              "[]" = "@class.outer";
            };
          };
          swap = {
            enable = true;
            swapNext = {
              "<leader>a" = "@parameters.inner";
            };
            swapPrevious = {
              "<leader>A" = "@parameter.outer";
            };
          };
        };
      };
    };
  };
}
