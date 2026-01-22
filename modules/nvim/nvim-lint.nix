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
            "markdownlint-cli2"
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
