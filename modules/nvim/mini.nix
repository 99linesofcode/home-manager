{ ... }:
{
  programs.nixvim = {
    keymaps = [
    ];

    plugins = {
      mini = {
        enable = true;
        mockDevIcons = true;
        modules = {
          ai = {
            n_lines = 50;
            search_method = "cover_or_next";
          };
          diff = {
            view = {
              style = "sign";
              options = {
                algorithm = "histogram";
              };
            };
          };
          icons = { };
          pairs = {
            modes = {
              insert = true;
              command = true;
              terminal = false;
            };
            skip_ts = [ "string" ];
            skip_unbalanced = true;
            markdown = true;
          };
          surround = {
            mappings = {
              add = "gsa";
              delete = "gsd";
              find = "gsf";
              find_left = "gsF";
              highlight = "gsh";
              replace = "gsr";
              update_n_lines = "gsn";
            };
          };
        };
      };
    };
  };
}
