{ ... }:
{
  programs.nixvim = {
    keymaps = [
    ];

    plugins = {
      lint = {
        enable = false;
        lintersByFt = {
          dockerfile = [
            "hadolint"
          ];
          json = [
            "jsonlint"
          ];
          markdown = [
            "vale"
          ];
          php = [
            "pint"
            "php_cs_fixer"
          ];
          rst = [
            "vale"
          ];
          ruby = [
            "ruby"
          ];
          rust = [
            "rustfmt"
          ];
          text = [
            "vale"
          ];
        };
      };
    };
  };
}
