{ ... }:
{
  programs.nixvim = {
    keymaps = [
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>d";
        action = "";
        options = {
          desc = "+debug";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>dB";
        action.__raw = ''
          function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end
        '';
        options = {
          desc = "Breakpoint Condition";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>db";
        action.__raw = ''
          function() require("dap").toggle_breakpoint() end
        '';
        options = {
          desc = "Toggle Breakpoint";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>dc";
        action.__raw = ''
          function() require("dap").continue() end
        '';
        options = {
          desc = "Continue";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>da";
        action.__raw = ''
          function() require("dap").continue({ before = get_args }) end
        '';
        options = {
          desc = "Run with Args";
        };
      }
      # { mode = "n"; "<leader>dC"; function() require("dap").run_to_cursor() end; desc = "Run to Cursor" };
      # { mode = "n"; "<leader>dg"; function() require("dap").goto_() end; desc = "Go to Line (No Execute)" };
      # { mode = "n"; "<leader>di"; function() require("dap").step_into() end; desc = "Step Into" };
      # { mode = "n"; "<leader>dj"; function() require("dap").down() end; desc = "Down" };
      # { mode = "n"; "<leader>dk"; function() require("dap").up() end; desc = "Up" };
      # { mode = "n"; "<leader>dl"; function() require("dap").run_last() end; desc = "Run Last" };
      # { mode = "n"; "<leader>do"; function() require("dap").step_out() end; desc = "Step Out" };
      # { mode = "n"; "<leader>dO"; function() require("dap").step_over() end; desc = "Step Over" };
      # { mode = "n"; "<leader>dp"; function() require("dap").pause() end; desc = "Pause" };
      # { mode = "n"; "<leader>dr"; function() require("dap").repl.toggle() end; desc = "Toggle REPL" };
      # { mode = "n"; "<leader>ds"; function() require("dap").session() end; desc = "Session" };
      # { mode = "n"; "<leader>dt"; function() require("dap").terminate() end; desc = "Terminate" };
      # { mode = "n"; "<leader>dw"; function() require("dap.ui.widgets").hover() end; desc = "Widgets" };
    ];

    # TODO: package vscode-php-debug OR interface with xdebug directly
    plugins.dap = {
      enable = false;
      adapters = {
        # php = {
        #   type = "executable";
        #   command = "node";
        #   args = "vscode-php-debug/out/phpDebug.js";
        # };
      };
      configurations = {
        # php = {
        #   type = "php";
        #   request = "launch";
        #   name = "Listen for Xdebug";
        #   port = 9003;
        # };
      };
    };
  };
}
