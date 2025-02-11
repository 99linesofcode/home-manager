{...}: {
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "[t";
        action.__raw = ''
          function() require("todo-comments").jump_prev() end
        '';
        options = {
          desc = "Prev Todo Comment";
        };
      }
      {
        mode = "n";
        key = "]t";
        action.__raw = ''
          function() require("todo-comments").jump_next() end
        '';
        options = {
          desc = "Next Todo Comment";
        };
      }
      {
        mode = "n";
        key = "xt";
        action = "<cmd>Trouble todo toggle<cr>";
        options = {
          desc = "Todo (Trouble)";
        };
      }
      {
        mode = "n";
        key = "xT";
        action = "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>";
        options = {
          desc = "Todo/Fix/Fixme (Trouble)";
        };
      }
      {
        mode = "n";
        key = "st";
        action = "<cmd>TodoTelescope<cr>";
        options = {
          desc = "Todo";
        };
      }
      {
        mode = "n";
        key = "sT";
        action = "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>";
        options = {
          desc = "Todo/Fix/Fixme";
        };
      }
    ];

    plugins.todo-comments = {
      enable = true;
    };
  };
}
