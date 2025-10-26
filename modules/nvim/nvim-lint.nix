{ ... }:
{
  programs.nixvim = {
    keymaps = [
    ];

    plugins = {
      lint = {
        enable = true;
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
            "phpstan"
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
          yaml = [
            "yq"
          ];
        };
      };
    };
  };
}
