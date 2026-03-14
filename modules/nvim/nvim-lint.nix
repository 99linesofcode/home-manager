{ ... }:
{
  programs.nixvim = {
    keymaps = [
    ];

    plugins = {
      lint = {
        enable = true;
        lintersByFt = {
          bash = [
            "shellcheck"
          ];
          dockerfile = [
            "hadolint"
          ];
          markdown = [
            "markdownlint-cli2"
            "vale"
          ];
          php = [
            "phpstan"
          ];
          ruby = [
            "rubocop"
          ];
          sh = [
            "shellcheck"
          ];
          text = [
            "vale"
          ];
          yaml = [
            "yamllint"
          ];
        };
      };
    };
  };
}
