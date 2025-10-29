{ ... }:
let
  model = "google/gemini-2.5-pro-exp-03-25:free";
in
{
  sops.secrets.openrouter_api_key = {
    format = "binary";
    sopsFile = ../../hosts/shared/secrets/openrouter_api_key;
    path = "%r/openrouter_api_key";
  };

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
          adapters = {
            openrouter.__raw = # lua
              ''
                function()
                  return require('codecompanion.adapters').extend('openai', {
                    name = "openrouter",
                    url = "https://openrouter.ai/api/v1/chat/completions",
                    env = {
                      api_key = "cmd: cat $XDG_RUNTIME_DIR/openrouter_api_key",
                      model = "schema.model.default",
                    },
                    formatted_name = "OpenRouter",
                    schema = {
                      model = {
                        default = "${model}"
                      },
                    },
                  })
                end
              '';
          };
          display = {
            chat = {
              show_settings = true;
            };
            diff = {
              provider = "mini_diff";
            };
          };
          strategies = {
            agent = {
              adapter = "openrouter";
            };
            chat = {
              adapter = "openrouter";
            };
            inline = {
              adapter = "openrouter";
            };
          };
        };
      };
    };
  };
}
