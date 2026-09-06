# [0.22.0](https://github.com/99linesofcode/home-manager/compare/v0.21.0...v0.22.0) (2026-09-06)


### Bug Fixes

* **github:** remove nested .github directory ([c8eb337](https://github.com/99linesofcode/home-manager/commit/c8eb33776819845fda9cbda268c014bd415381ec))
* **nvim:** enable autoread so the editor picks up on ACP server changes ([fa9767a](https://github.com/99linesofcode/home-manager/commit/fa9767a763a1cdb85178a8eaed9aeb26a253431f))
* **obs:** correctly set QT_QPA_PLATFORM and optionally enable wlroots plugin ([d8cae84](https://github.com/99linesofcode/home-manager/commit/d8cae84f5fa0edb265d3820762c408329a8b8a91))
* **obsidian:** only run activation script on first run ([55b0aaa](https://github.com/99linesofcode/home-manager/commit/55b0aaab404463325512e987c64ca5797bf3989a))
* **opencode:** enable EXA for websearch ([15dc4ab](https://github.com/99linesofcode/home-manager/commit/15dc4ab94ca211e414551750dd293ca29171099c))
* **opencode:** set permissive permissions but lock down filesystem and set bash to ask ([1b2fe46](https://github.com/99linesofcode/home-manager/commit/1b2fe46d97353a1ff0a0a4a800bdf05212394901))
* **sops:** look for secrets in the derivation output path to avoid impure errors ([dad6179](https://github.com/99linesofcode/home-manager/commit/dad617930d56be25e88f1ee7680a940a5e4ee9e4))
* **typst:** use unstable as that has support for variable font sizes ([cfbe24a](https://github.com/99linesofcode/home-manager/commit/cfbe24a96a56b10daf809921dc5f4e04cba58db4))
* **voxtype:** use toggle instead of press and hold ([51e5ec1](https://github.com/99linesofcode/home-manager/commit/51e5ec12141ba4413be14ecfa9c2e07eb1d2e1f0))


### Features

* **discord:** added Discord MCP server ([e943760](https://github.com/99linesofcode/home-manager/commit/e943760ad0e3bd6ca038ca7026ccf16afc8e0811))
* **firefox:** allow converting web content to markdown files using obsidian web clipper ([e15ef03](https://github.com/99linesofcode/home-manager/commit/e15ef037273294648b7a2ab1be6a9811ecadc2a3))
* **git:** added GitHub MCP server ([bb27720](https://github.com/99linesofcode/home-manager/commit/bb27720088db51d4c4cc4de73899e88039679246))
* **obsidian:** add support for the MCP protocl using seekstone ([0a9897b](https://github.com/99linesofcode/home-manager/commit/0a9897b3a724c5e23afb20614395029d388bf873))
* **opencode:** enable MCP for Google Workspace and Todoist ([0ff02d3](https://github.com/99linesofcode/home-manager/commit/0ff02d31a3ce910ebec4216ee7e9c73233dc0218))
* **opencode:** expand SKILLs catalog ([1374db4](https://github.com/99linesofcode/home-manager/commit/1374db42715e0d69fcb7bed0df6ed6b103768843))
* **opencode:** full user access but disable destructive operations ([11a5e3e](https://github.com/99linesofcode/home-manager/commit/11a5e3eff9307b9d24cfdc08c175e64d5ae8bf11))
* **opencode:** read global agents/ and skills/ from home-manager/.opencode directory ([5d0d38f](https://github.com/99linesofcode/home-manager/commit/5d0d38f8c872959af04ce5c2d398a2b4d1ab67b1))
* **opencode:** scaffold module and default to deepseek v4 for now ([7967796](https://github.com/99linesofcode/home-manager/commit/7967796278775779addea6018cfd8c46d0c20e57))
* **openssh:** enable services.ssh-agent so $SSH_AUTH_SOCK is always available ([cb614a9](https://github.com/99linesofcode/home-manager/commit/cb614a9e62f2d0287de463c7da9baab650ae7201))
* **voxtype:** enable meeting mode ([7dcdc0b](https://github.com/99linesofcode/home-manager/commit/7dcdc0bcc1a1fb4d725c35ee78a6d8ba5db79bf7))
* **voxtype:** enable waybar status indicator ([edc5336](https://github.com/99linesofcode/home-manager/commit/edc5336ac4b8cb55bc6dc3b98e98602873c511ad))
* **voxtype:** max recording duration is now set to 5 minutes ([82168ab](https://github.com/99linesofcode/home-manager/commit/82168ab4dae3e655da59a92667795ef1a628ac52))
* **voxtype:** Voice-to-text with push-to-talk for Wayland compositors ([5801737](https://github.com/99linesofcode/home-manager/commit/580173705e4c3e8e1a326ea73df738cef1c16587))
* **zed:** scaffold module for Zed, the GPU accelerated text editor ([0014fb0](https://github.com/99linesofcode/home-manager/commit/0014fb02b1df2e925e9675b497cf96a958fd7beb))



# [0.21.0](https://github.com/99linesofcode/home-manager/compare/v0.20.2...v0.21.0) (2026-07-06)


### Bug Fixes

* **hyprpaper:** hyprctl hyprpaper was called incorrectly ([d2dca52](https://github.com/99linesofcode/home-manager/commit/d2dca52f8a73053967e43dcf32b466eada3092b4))
* **obs:** write input-overlay presets in .config/obs-studio ([088f807](https://github.com/99linesofcode/home-manager/commit/088f80750b7f78a0f4905a22b9f1d8e17a53d676))
* **sops:** defaultSopsFile should point to a secrets file, not the .sops config ([49430a6](https://github.com/99linesofcode/home-manager/commit/49430a6602f1321d04a26b7a4904874cfee921a7))
* **sops:** master key decrypts everything and hosts don't need access to hm secrets ([9b26fa7](https://github.com/99linesofcode/home-manager/commit/9b26fa753143c1c79530b420a65a1eef551fb064))
* **sops:** use ${username}.txt age key and generate it if it doesn't exist ([4595b46](https://github.com/99linesofcode/home-manager/commit/4595b460954763649da7f7cb7ef0136e6f4fbc3e))
* use dedicated release versions for other flakes as well ([03d522d](https://github.com/99linesofcode/home-manager/commit/03d522d9ac1231c0d1ce6393b5d26198a2d8dad1))


### Features

* **bitwarden:** replace desktop with CLI ([c67695a](https://github.com/99linesofcode/home-manager/commit/c67695af3b2c9253e9a7c6a6d1eda7b4a468deaa))
* **obsidian:** run bisync --resync on initial run ([60aac98](https://github.com/99linesofcode/home-manager/commit/60aac9810e19a3083c6c9fb84ceaba83fa1abd7f))
* **rclone:** define files that can optionally be ignored ([d5881f7](https://github.com/99linesofcode/home-manager/commit/d5881f7a57f016b277770cf4ab92188f9df927f6))
* **syncthing:** add fairphone device ID ([410ca48](https://github.com/99linesofcode/home-manager/commit/410ca4813798f858d13776456c88fe2a2a2ece8d))
* **typst:** convert .md files to PDFs using Pandoc and Typst ([44e9c71](https://github.com/99linesofcode/home-manager/commit/44e9c71384646f48f7b40640cb60550bce3a118d))



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



