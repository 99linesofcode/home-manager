{
  lib,
  pkgs,
  ...
}:
let
  codelldb = {
    name = "Launch (CodeLLDB)";
    type = "codelldb";
    request = "launch";
    program.__raw = ''
      function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. '/', "file")
      end
    '';
  };
  gdb = {
    name = "Launch (GDB)";
    type = "gdb";
    request = "launch";
    program.__raw = ''
      function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. '/', "file")
      end
    '';
  };
in
{
  home.packages = with pkgs; [
    vscode-extensions.xdebug.php-debug
  ];

  programs.nixvim = {
    plugins = {
      dap = {
        enable = true;
        adapters = with pkgs; {
          executables = {
            php = {
              command = lib.getExe' nodePackages.nodejs "node";
              args = [
                "${vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js"
              ];
            };
          };
          servers = {
            codelldb = {
              port = 9000;
              executable = {
                command = "${vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
                args = [
                  "--port"
                  "9000"
                ];
              };
            };
          };
        };
        configurations = {
          c = [
            codelldb
            gdb
          ];
          cpp = [
            codelldb
            gdb
          ];
          php = [
            {
              name = "Listen for Xdebug";
              type = "php";
              request = "launch";
              port = 9003;
            }
          ];
          rust = [
            codelldb
            gdb
          ];
        };
        signs = {
          dapBreakpoint = {
            text = "";
            texthl = "DapBreakpoint";
          };
          dapBreakpointCondition = {
            text = "";
            texthl = "dapBreakpointCondition";
          };
          dapBreakpointRejected = {
            text = "";
            texthl = "DapBreakpointRejected";
          };
          dapLogPoint = {
            text = "";
            texthl = "DapLogPoint";
          };
          dapStopped = {
            text = "";
            texthl = "DapStopped";
          };
        };
      };
      dap-ui.enable = true;
      dap-virtual-text.enable = true;
    };

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
      # {
      #   mode = [ "n" ];
      #   key = "<leader>da";
      #   action.__raw = ''
      #     function() require("dap").continue({ before = get_args }) end
      #   '';
      #   options = {
      #     desc = "Run with Args";
      #   };
      # }
      {
        mode = [ "n" ];
        key = "<leader>dC";
        action.__raw = ''
          function() require("dap").run_to_cursor() end
        '';
        options = {
          desc = "Run to Cursor";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>dg";
        action.__raw = ''
          function() require("dap").goto_() end
        '';
        options = {
          desc = "Go to Line (No Execute)";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>di";
        action.__raw = ''
          function() require("dap").step_into() end
        '';
        options = {
          desc = "Step Into";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>dj";
        action.__raw = ''
          function() require("dap").down() end
        '';
        options = {
          desc = "Down";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>dk";
        action.__raw = ''
          function() require("dap").up() end
        '';
        options = {
          desc = "Up";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>dl";
        action.__raw = ''
          function() require("dap").run_last() end
        '';
        options = {
          desc = "Run Last";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>do";
        action.__raw = ''
          function() require("dap").step_out() end
        '';
        options = {
          desc = "Step Out";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>dO";
        action.__raw = ''
          function() require("dap").step_over() end
        '';
        options = {
          desc = "Step Over";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>dp";
        action.__raw = ''
          function() require("dap").pause() end
        '';
        options = {
          desc = "Pause";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>dr";
        action.__raw = ''
          function() require("dap").repl.toggle() end
        '';
        options = {
          desc = "Toggle REPL";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>ds";
        action.__raw = ''
          function() require("dap").session() end
        '';
        options = {
          desc = "Session";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>dt";
        action.__raw = ''
          function() require("dap").terminate() end
        '';
        options = {
          desc = "Terminate";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>dw";
        action.__raw = ''
          function() require("dap.ui.widgets").hover() end
        '';
        options = {
          desc = "Widgets";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>du";
        action.__raw = ''
          function() require("dapui").toggle() end
        '';
        options = {
          desc = "Dap UI";
        };
      }
      {
        mode = [ "n" ];
        key = "<leader>de";
        action.__raw = ''
          function() require("dapui").eval() end
        '';
        options = {
          desc = "Eval";
        };
      }
    ];

  };
}
