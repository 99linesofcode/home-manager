## [0.20.2](https://github.com/99linesofcode/home-manager/compare/v0.20.1...v0.20.2) (2026-06-25)


### Bug Fixes

* **zsh:** uwsm is not kicked off through the hyprland-uwsm.desktop file and PAM ([0b3cee7](https://github.com/99linesofcode/home-manager/commit/0b3cee769fd87773359409905379101b2665cb4a))



## [0.20.1](https://github.com/99linesofcode/home-manager/compare/v0.20.0...v0.20.1) (2026-06-09)


### Bug Fixes

* **firefox:** scaling issue in extensions ([580a6f5](https://github.com/99linesofcode/home-manager/commit/580a6f52fe4a5fc5109244de73c4a51c2a48d951))



# [0.20.0](https://github.com/99linesofcode/home-manager/compare/v0.19.0...v0.20.0) (2026-06-06)


### Bug Fixes

* **conform.nvim:** don't squeeze or trim, it'll be handled by editorconfig/formatters ([a144362](https://github.com/99linesofcode/home-manager/commit/a1443623bdfb202119ea6fc247fcaa0095faf09b))
* **dependabot:** time should be of type string instead of int ([fc50350](https://github.com/99linesofcode/home-manager/commit/fc503500951c8c7ee775f0c3d6fec22ec101d304))
* **feh:** disable override as imlib2 build argument no longer exists ([6cd01fa](https://github.com/99linesofcode/home-manager/commit/6cd01fa3c7381feff5a01c27afe9adaa5fd30f79))
* **firefox:** configuration is now stored and read from XDG_CONFIG_HOME ([c840bbb](https://github.com/99linesofcode/home-manager/commit/c840bbb379a91e0a16c16f39d3a2aa9b722f8c30))
* **freecad:** freecad-wayland no longer exists and freecad presently doesn't build ([b7d2376](https://github.com/99linesofcode/home-manager/commit/b7d23766f90d3b85ea84bcaed7c282eda8a92444))
* **ghidra:** now builds correctly again ([db7b9ec](https://github.com/99linesofcode/home-manager/commit/db7b9ec12ea729aa29dcab7dd4510b66e9bc0276))
* **git:** aliases setting shouldve been alias ([c2b343f](https://github.com/99linesofcode/home-manager/commit/c2b343f52252d01f2c8eb06386bb387706a9c1b7))
* **hyprland:** dispatch togglesplit has been replaced with layoutmsg ([1796df6](https://github.com/99linesofcode/home-manager/commit/1796df6c36b1c3fdbdf5b19641f12fd922d17241))
* **hyprland:** set configType to the legacy hyprlang ([3e6ef47](https://github.com/99linesofcode/home-manager/commit/3e6ef47f6df81d34e9edc4989be5928e0d3e54a8))
* **mars.shorty:** enable styling with stylix ([12b8e33](https://github.com/99linesofcode/home-manager/commit/12b8e33aa00406947351a487fd163d2088a47817))
* **nvim-cmp:** disable lsp document symbol while the licensing issue is resolved ([df4f371](https://github.com/99linesofcode/home-manager/commit/df4f371f1e311095773d843c46da7fb614ebef64))
* **nvim:** settings entries were renamed to snake_case instead of camelCase ([801cbc6](https://github.com/99linesofcode/home-manager/commit/801cbc6914b02f6d762e348f954a06e1e0a45788))
* **sops:** use age key generated for host by nixos-config ([ddbe338](https://github.com/99linesofcode/home-manager/commit/ddbe338df3631ef93c132b2e3f625fe8e94a9745))
* **telescope.nvim:** live_grep hidden files ([fed58f6](https://github.com/99linesofcode/home-manager/commit/fed58f6bf50644b99d5e6c31111b6edc37f122c7))
* **telescope.nvim:** search hidden files and directories unless [.gitignore|.ignore]d ([8537da7](https://github.com/99linesofcode/home-manager/commit/8537da7722c0385f0128b831d0357313b4f150e9))
* **yazi:** settings.manager was renamed to settings.mgr ([16ea454](https://github.com/99linesofcode/home-manager/commit/16ea4543a3329fbd4f069124de5cdb2827966a7d))
* **yazi:** suppress shell wrapper rename warning by being explicit ([6f29d71](https://github.com/99linesofcode/home-manager/commit/6f29d71b577e4069b2c9c579738612fce9f14df3))
* **zellij:** use default layout as this displays the keybindings on CTRL B ([939f97e](https://github.com/99linesofcode/home-manager/commit/939f97e6ea16e4aa38e5d85290971d7a0d5c22fb))


### Features

* **act:** run GitHub Actions from your local dev machine ([5957713](https://github.com/99linesofcode/home-manager/commit/5957713fd172f5b290b46104faf056fdbe14834b))
* **firefox:** enable fake-filler extension ([100cae5](https://github.com/99linesofcode/home-manager/commit/100cae5bc7d6a0a0ff1a49f012710056c97637f2))
* **git:** add git filter-repo to simplify history management ([3fd3cb7](https://github.com/99linesofcode/home-manager/commit/3fd3cb7865324e7667630cfb2bdac8e415906c8c))
* **github:** let dependabot automatically update git submodules ([bc91a14](https://github.com/99linesofcode/home-manager/commit/bc91a14f507d7a6082e469b09b90bbb6e8590ed2))
* install native ET:Legacy client ([6972709](https://github.com/99linesofcode/home-manager/commit/6972709378ae58aa1ccce5f0b3d7e839042d9f8d))
* **lazysql:** TUI client for SQL ([af6a6c5](https://github.com/99linesofcode/home-manager/commit/af6a6c5d901bc5253da2003f5b3030280bab5220))
* **nvim:** add dotenv filetype and make sure .env files are detected as much ([dfd2b51](https://github.com/99linesofcode/home-manager/commit/dfd2b516be6b82b1f66ef8955c26330fcfba984b))
* **nvim:** add line length rulers at 80, 120 and 160 characters ([4e0cd59](https://github.com/99linesofcode/home-manager/commit/4e0cd59e499a20d65d481a613c8d0022b857bbf7))
* **nvim:** allow aligning code through mini-align ([2525fd8](https://github.com/99linesofcode/home-manager/commit/2525fd8726791954dbdbe86b8e471ea570e8ae62))
* **nvim:** autocompletions for method signature, symbols and treesitter parser ([74a93b7](https://github.com/99linesofcode/home-manager/commit/74a93b7f7447c7afe0cd93452cc239e4da108374))
* **nvim:** display diagnostics on virtual line with lsp-lines ([4604a68](https://github.com/99linesofcode/home-manager/commit/4604a683f878a00ea409d3406465e016f0510140))
* **nvim:** force mini-icons to use glyphs ([0da7ebc](https://github.com/99linesofcode/home-manager/commit/0da7ebc3d5e042ed96e76d0cfec7819e8f75851d))
* **nvim:** formatting sql with sqlruff ([36f5ae1](https://github.com/99linesofcode/home-manager/commit/36f5ae1d027941735e5b4854eac74e00e01e82a6))
* **nvim:** handle linting, formatting and error checking at lsp, nvim-lint or conform level ([f1baa44](https://github.com/99linesofcode/home-manager/commit/f1baa4411deeb4153497da1a4969fa7cc46be918))
* **nvim:** install language servers and linters that should be globally available ([54ad52b](https://github.com/99linesofcode/home-manager/commit/54ad52b8e0ca18ed278e15fcd625fc92713cbdcf))
* **nvim:** lint markdown using markdownlint-cli2 as well as vale for prose ([d13bcad](https://github.com/99linesofcode/home-manager/commit/d13bcad3941177da182ef7680c309217c7e015ad))
* **nvim:** split or join arguments easily using mini-splitjoin ([d58b7a6](https://github.com/99linesofcode/home-manager/commit/d58b7a6fe5ca0f3c6705d96bd5816960692b9d85))
* **yazi:** override default window behavior in hyprland ([f142a3c](https://github.com/99linesofcode/home-manager/commit/f142a3cb7fe298d2b686a7515f47244629a26953))
* **zsh:** run artisan OR testbench in docker OR local with a() and p() ([c3c266c](https://github.com/99linesofcode/home-manager/commit/c3c266c9fbf6c3794f3adbff613f268a6f53acac))
* **zsh:** run artisan OR testbench in docker OR local with a() and p() ([2620efb](https://github.com/99linesofcode/home-manager/commit/2620efb5ea52fb58346c69f6d7ef36b138a0c973))



# [0.19.0](https://github.com/99linesofcode/home-manager/compare/v0.18.1...v0.19.0) (2026-01-30)


### Bug Fixes

* **google-drive:** enable module only when rclone and google-drive are enabled ([5415f5c](https://github.com/99linesofcode/home-manager/commit/5415f5c8c9b0cbdaf376c4761e308aaaad50b4dc))
* **nvim:** neo-tree settings are passed as is not translated from camelCase to snake_case ([e1a5b1c](https://github.com/99linesofcode/home-manager/commit/e1a5b1c62ac1e24255402b947912d77277fb97ee))
* **nvim:** nvim-treesitter settings are passed as is not translated from camelCase to snake_case ([96f69a0](https://github.com/99linesofcode/home-manager/commit/96f69a0e635120e8354d68e42d2a803c595dfccf))
* **syncthing:** enable only when google-drive AND obsidian are enabled ([5f54988](https://github.com/99linesofcode/home-manager/commit/5f54988bd4b377144301dde04a74210c23e9650c))
* **syncthing:** opt-out of sharing anonymous usage data ([b8541d5](https://github.com/99linesofcode/home-manager/commit/b8541d5fd157fd1d19fda3856f014b387dd334ef))


### Features

* **firefox:** custom search engines for Sonarr and Radarr ([e642e4d](https://github.com/99linesofcode/home-manager/commit/e642e4d2dfe0c4e49dd8cc32ac2e0d847582ded3))
* **syncthing:** add module for peer-to-peer file synchronization ([9461a5e](https://github.com/99linesofcode/home-manager/commit/9461a5e8a017f1f6e527e4647f178c085bbc01b4))



## [0.18.1](https://github.com/99linesofcode/home-manager/compare/v0.18.0...v0.18.1) (2026-01-12)


### Bug Fixes

* **nvim:** expand all folds ([ab8f34e](https://github.com/99linesofcode/home-manager/commit/ab8f34efa1d0b2959024bf085a11349bdce70601))



