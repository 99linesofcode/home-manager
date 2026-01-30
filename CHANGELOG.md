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



# [0.18.0](https://github.com/99linesofcode/home-manager/compare/v0.17.0...v0.18.0) (2026-01-12)


### Bug Fixes

* disable installing ghidra and overriding feh.imlib2 with imlib2Full for the time being ([aa44507](https://github.com/99linesofcode/home-manager/commit/aa44507eb040e43285ef0faaa6e2a77570922215))
* **hyprland:** allow navigating and cycling to other half of the workspaces ([20f8eee](https://github.com/99linesofcode/home-manager/commit/20f8eee161c8f04cb6c2a98036a6393f8c428b1a))
* **hyprpaper:** disable rendering hyprland splash on wallpaper ([78d2363](https://github.com/99linesofcode/home-manager/commit/78d2363473c242a168e063ddc61f91a79b62403b))
* **nvim:** couldn't run lazygit as sub process due to missing .cache/nvim directory ([134e09d](https://github.com/99linesofcode/home-manager/commit/134e09dd80bb0c48a9063904eb65ca85069d3240))
* **sops:** stops at first match so order of creation_rules is important ([827d6e2](https://github.com/99linesofcode/home-manager/commit/827d6e22742033e1ba9c31a43f6e96cc3131eee3))
* **xdg:** enable creating XDG base directories and setting the env variables ([82fa48a](https://github.com/99linesofcode/home-manager/commit/82fa48afc95a204cde1f818fc4954cfad32997b7))
* **xwayland:** resolve scaling issues for xwayland applications ([f5d6a4e](https://github.com/99linesofcode/home-manager/commit/f5d6a4ea8fbe24a9d00d77b4fc5b807f2cbc5a4a))


### Features

* **hyprmon:** TUI monitor configuration tool for Hyprland with visual layout ([43b1a29](https://github.com/99linesofcode/home-manager/commit/43b1a296a09bbe740a54a32e0b6e30e677a0ac1c))
* **hyprpointer:** The hyprland cursor format ([001fb76](https://github.com/99linesofcode/home-manager/commit/001fb764238955b6f361a6609a4699f9c84f7c1e))



# [0.17.0](https://github.com/99linesofcode/home-manager/compare/v0.16.0...v0.17.0) (2025-10-26)


### Bug Fixes

* **nvim-conform:** don't run shellharden in sh ([ee46a77](https://github.com/99linesofcode/home-manager/commit/ee46a7717f8c94a9c53eb0d107fd7c61d01e0ef9))
* **nvim:** php linting using phpstan ([4a42df7](https://github.com/99linesofcode/home-manager/commit/4a42df743489391571af5e91fd668c387dfcd751))
* **openssh:** automatically forward agent and keep connection alive ([3881051](https://github.com/99linesofcode/home-manager/commit/3881051098680b7a67389ebe491891f8dcdcbd16))
* **waybar:** assume impala since nmtui won't be installed ([0b45065](https://github.com/99linesofcode/home-manager/commit/0b45065e2eecb00418d0e16b5ced70cb8f5dbe6c))
* **waybar:** hardcode network interface to prevent faulty autoselect ([fc8842b](https://github.com/99linesofcode/home-manager/commit/fc8842be5c100193d866b9c4515611b2dd753a0e))
* **zsh:** only add uwsm start to .zprofile if wayland is enabled ([3c9a6b5](https://github.com/99linesofcode/home-manager/commit/3c9a6b51c90df4c847d0d4b7a763e5f5782d24c5))
* **zsh:** running artisan in container or local using the a() function ([35e78c2](https://github.com/99linesofcode/home-manager/commit/35e78c2cf1b1b5d2111b0c5085c9df53fcd6273f))


### Features

* **alias:** run both artisan and composer in docker container if available ([95a72bd](https://github.com/99linesofcode/home-manager/commit/95a72bd04215eab089caa035e47db74a88fa1c1d))
* **deploy:** let nixos-config handle initial provisioning ([8b8172b](https://github.com/99linesofcode/home-manager/commit/8b8172b9bb657a0b050f1e546ec2785117c2bf94))
* **deploy:** succesful deployment of the mars host ([7cc7ee1](https://github.com/99linesofcode/home-manager/commit/7cc7ee13c6c5793c2ed18248d95a2ecdbd16239d))
* **espanso:** a text expander ([7e5fd1b](https://github.com/99linesofcode/home-manager/commit/7e5fd1b3a5e43b5c402e52a231e8e042b27377f2))
* **impala:** iwd based TUI wifi manager ([3fb2154](https://github.com/99linesofcode/home-manager/commit/3fb21541cd52731b9092dd0531117dc2ed94fd03))
* install jq and yq globally ([0e24dca](https://github.com/99linesofcode/home-manager/commit/0e24dca161850f6eabe21aed31eef08716b5f1a1))



# [0.16.0](https://github.com/99linesofcode/home-manager/compare/v0.15.0...v0.16.0) (2025-09-05)


### Bug Fixes

* make shell functions POSIX compliant ([2ab1b68](https://github.com/99linesofcode/home-manager/commit/2ab1b6831292a0d948314acfcff38b58ac328148))
* **nvim:** calling bdelete closed the whole editor session ([e7215a7](https://github.com/99linesofcode/home-manager/commit/e7215a7a2d3a9f5b7316f5076ce8ce38952b8d46))
* **nvim:** disable flash autojump on single result ([26d304e](https://github.com/99linesofcode/home-manager/commit/26d304ed509cb7dcbc2f484220c3cd4143dc1ae0))
* **obsidian:** automatically bounce back from almost any interruption ([e740c31](https://github.com/99linesofcode/home-manager/commit/e740c314b7543d7e27a4762eb15c31332f62df0d))
* **steam:** missing fonts causing Wine installation wizards to crash ([6b3187d](https://github.com/99linesofcode/home-manager/commit/6b3187d27f58c71f6da3967ff4c673fa256bce3c))
* **vscode:** blade formatting using vscode-blade-formatter ([7935469](https://github.com/99linesofcode/home-manager/commit/793546926810cf23250663989726ae2666dab42c))
* **vscode:** emmet completions didnt work for TailwindCSS ([e705ed1](https://github.com/99linesofcode/home-manager/commit/e705ed1892d5d8a00a0f322fe25ea19ba4b903d0))
* **vscode:** typo in eslint.validate block ([6a37f1a](https://github.com/99linesofcode/home-manager/commit/6a37f1a0a07df9d0ceb8e4b94455009a425594fc))
* **zsh:** enable zsh integration for fzf ([4f5c92c](https://github.com/99linesofcode/home-manager/commit/4f5c92c4213b7651ab5061f1a8f28af9adc4a672))
* **zsh:** history substring search was not using fzf ([8c511b4](https://github.com/99linesofcode/home-manager/commit/8c511b47208d727bff3adcdab7e12c33ca1df281))


### Features

* **artisan:** automatically run inside PHP container if present ([712b2f0](https://github.com/99linesofcode/home-manager/commit/712b2f0e782eda1b45b585ae45926a367d0ff09f))
* **docker:** use gnome keyring as credential store ([122a00e](https://github.com/99linesofcode/home-manager/commit/122a00e1f18af82b00c801af6b90d1908978482f))
* **firefox:** add vuejs devtools ([aebe150](https://github.com/99linesofcode/home-manager/commit/aebe15005e9040ff22ea02d87985ac84ddac15a2))
* **git:** enable github cli ([e77e483](https://github.com/99linesofcode/home-manager/commit/e77e4839643f2f84049b4d241e25250123a38f9a))
* **git:** update submodules on pull ([5739de3](https://github.com/99linesofcode/home-manager/commit/5739de39065fae6036f14ce8c228005e47fa9f6a))
* **insomnia:** FOSS Postman alternative ([9d02f92](https://github.com/99linesofcode/home-manager/commit/9d02f9272b95ff840c7e10b1092a38e7b959c422))
* install nil and nixfmt-rfc system wide ([bdcdf1f](https://github.com/99linesofcode/home-manager/commit/bdcdf1f94c7281f0cc61a99f5689b20aff55e526))
* **nvim:** fix yaml linting and formatting by using yq-go ([4768487](https://github.com/99linesofcode/home-manager/commit/47684873a7c7555863823f8fbe2ddc6f8bb9588f))
* **nvim:** install helm language server ([4264ddb](https://github.com/99linesofcode/home-manager/commit/4264ddb5c793c0f403863d3fe5a86772e284eda2))
* **vscode:** add todo-tree styling ([2fdf2dd](https://github.com/99linesofcode/home-manager/commit/2fdf2dd7818fd4f6960b605478b49374d53d2cd6))
* **vscode:** Vuejs syntax highlighting, formatting, etc. ([495563f](https://github.com/99linesofcode/home-manager/commit/495563f53c945089ad35fa118e8aaa2d51983293))



