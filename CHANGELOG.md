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



# [0.15.0](https://github.com/99linesofcode/home-manager/compare/v0.14.0...v0.15.0) (2025-05-19)


### Features

* **hyprpicker:** module for colorpicking ([e69f8f1](https://github.com/99linesofcode/home-manager/commit/e69f8f11fc2095defd11fc3d097519a72d17897a))



# [0.14.0](https://github.com/99linesofcode/home-manager/compare/v0.13.0...v0.14.0) (2025-05-19)


### Bug Fixes

* **stylix:** style correct vscode profile instead of the default ([388a1af](https://github.com/99linesofcode/home-manager/commit/388a1af0eb38081b2bed3e50ff5fc6e1e43edef4))
* **vscode-neovim:** disable neovim configuration in vscode context ([f5698d2](https://github.com/99linesofcode/home-manager/commit/f5698d2bc99f30d33f493dbcb1a856ee6651e771))
* **vscode:** configure html formatter to force attributes on new line ([291e1de](https://github.com/99linesofcode/home-manager/commit/291e1de8d4bdb94ed5ceebdbb3021d892e2f8739))
* **vscode:** force font sizes as other windows do not inherit editor.fontSize ([bcaf221](https://github.com/99linesofcode/home-manager/commit/bcaf22141c08c2345a08f5d0383729cc2532ee71))
* **vscode:** ignore files in .gitignore on search by default ([cf49167](https://github.com/99linesofcode/home-manager/commit/cf4916778bee64b2b702a0ce6142f15a72d7f466))
* **vscode:** key remapping is handled at kernel level now ([d2c8c52](https://github.com/99linesofcode/home-manager/commit/d2c8c52fe83105916b8889c6f3b7d05dfa4a7421))
* **vscode:** read extensions from correct nixpkgs ([4f5ff2a](https://github.com/99linesofcode/home-manager/commit/4f5ff2a013861352da6b6f8f32875e5143c7f2d3))
* **vscode:** use html formatter for blade files since blade doesnt play nice with livewire ([517a3bf](https://github.com/99linesofcode/home-manager/commit/517a3bf5e3fc62b2793283dd9518c9db5a2f40c9))


### Features

* **firefox:** completely disable Pocket for added performance boost ([409b9dc](https://github.com/99linesofcode/home-manager/commit/409b9dc4022eae256ec34dc22f3b33f046fe08e1))
* **firefox:** declare default application ([f015b83](https://github.com/99linesofcode/home-manager/commit/f015b83fc03d6554115a64b8b5bad3186fbb5e27))
* **nvim-lsp:** intelephense instead of phpactor as lsp ([add025c](https://github.com/99linesofcode/home-manager/commit/add025c99f9721ab2220dd6b1d55d92f6f13cd66))
* **steam:** replace protonup with steamtinkerlaunch ([80e9696](https://github.com/99linesofcode/home-manager/commit/80e96962e0decf6eb00e0ba9e09b709856c460b7))
* **vscode:** keybinds for todo tree and cline ([6fae63a](https://github.com/99linesofcode/home-manager/commit/6fae63ac529a8e44373b57227c8957a48f6475af))
* **vscode:** removed unnecessary UI element cluttering up the workspace ([08eeee4](https://github.com/99linesofcode/home-manager/commit/08eeee4f1a50d3bbae297b72c2bc48d204da4077))
* **vscode:** toggle and focus sidebar ([9e6bc71](https://github.com/99linesofcode/home-manager/commit/9e6bc714e7945ba6a4174a466c4bfb382da627c0))



# [0.13.0](https://github.com/99linesofcode/home-manager/compare/v0.12.0...v0.13.0) (2025-04-14)


### Bug Fixes

* **mpv:** no need to manually define yazi opener rules ([c88eb1d](https://github.com/99linesofcode/home-manager/commit/c88eb1d16b82ea718032084efaa51551575fb46e))
* **obsidian:** timer was not registered correctly ([5688cfb](https://github.com/99linesofcode/home-manager/commit/5688cfb9332826a2b2d7e4c3729889c4c1c55b07))


### Features

* allow declaring default mime type associations ([5f4e30b](https://github.com/99linesofcode/home-manager/commit/5f4e30bfdfe1c7374388884a86057f72b87e43a3))
* **feh:** declare default application for common mimetypes ([6a17a0b](https://github.com/99linesofcode/home-manager/commit/6a17a0b3cc3920c2a9e442c5b6c2a2542f22f41a))
* **firefox:** custom search engine for the ArchLinux wiki ([23ac9da](https://github.com/99linesofcode/home-manager/commit/23ac9da2bf67524ebbe8a376f642e7df9bae7723))
* **gammastep:** automatically adjust color temperature ([c614d5b](https://github.com/99linesofcode/home-manager/commit/c614d5b890fd7108fad6bc5857c70ef02347d86e))
* **hypridle:** reduce brightness, lock, turn off screen, suspend ([5ab1c16](https://github.com/99linesofcode/home-manager/commit/5ab1c165d408bde9f98df5bd56b74ca3370420ca))
* **hyprlock:** display date and time on lock screen ([4ece5ab](https://github.com/99linesofcode/home-manager/commit/4ece5ab77e8d3aa470745406424df747e5725591))
* **hyprpaper:** load a random wallpaper every 30 minutes ([4056f80](https://github.com/99linesofcode/home-manager/commit/4056f80ec7b78642367f9e82c73d1bd9a988c7ab))
* **zathura:** declare default application for common mimetypes ([7a3d45a](https://github.com/99linesofcode/home-manager/commit/7a3d45a02f81ed433b64ccddafb31cd8ecb4a750))



# [0.12.0](https://github.com/99linesofcode/home-manager/compare/v0.11.0...v0.12.0) (2025-04-10)


### Bug Fixes

* disable rustdesk and vscode as they fail to build atm ([dac424f](https://github.com/99linesofcode/home-manager/commit/dac424f80fea665f60c1de052e096ec79786127f))
* **zellij:** disable startup tips ([92e9fa4](https://github.com/99linesofcode/home-manager/commit/92e9fa42cd032cfdda94f6dcd8c60f245eecaa5a))


### Features

* **mpv:** configure yazi open rules if yazi is enabled ([d0e308b](https://github.com/99linesofcode/home-manager/commit/d0e308b90d975b28fb6a36d7da8df4634aa4d4ea))
* **ssh:** configure agent forwarding and keep alive where relevant ([8e97416](https://github.com/99linesofcode/home-manager/commit/8e97416f772b9bd5cb0ba88031c324d026d189bc))
* **yazi:** sensible default configuration ([d350b1a](https://github.com/99linesofcode/home-manager/commit/d350b1aa9121634b5f853e4051016a152beb3efd))
* **zsh:** start hyprland through uwsm on profile load ([74496e2](https://github.com/99linesofcode/home-manager/commit/74496e21c49dd3a9be4dd101bfa8b12ee8ef47b0))



