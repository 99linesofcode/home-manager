{ ... }:
{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>cca";
        action = "<cmd>CodeCompanionActions<cr>";
        options = {
          desc = "CodeCompanion Actions";
        };
      }
      {
        mode = "n";
        key = "<leader>ccc";
        action = "<cmd>CodeCompanionChat<cr>";
        options = {
          desc = "CodeCompanion Chat";
        };
      }
    ];

    # TODO: seems code completion with nvim-cmp doesn't work yet
    plugins = {
      codecompanion = {
        enable = true;
        settings = {
          display = {
            chat = {
              show_settings = true;
            };
            diff = {
              provider = "mini_diff";
            };
          };
          interactions = {
            chat = {
              adapter = "opencode";
            };
            cli = {
              adapter = "opencode";
            };
            inline = {
              adapter = "opencode";
            };
            background = {
              adapter = "opencode";
            };
          };
        };
      };
    };
  };
}
