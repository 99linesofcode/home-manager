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
            "vale"
          ];
          sh = [
            "shellcheck"
          ];
          text = [
            "vale"
          ];
        };
      };
    };
  };
}
