{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Visual Studio Code
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      forEachSystem = f: nixpkgs.lib.genAttrs systems f;

      pkgsForSystem =
        system: nixpkgsSource:
        import nixpkgsSource {
          inherit system;
          overlays = [
            inputs.nix-vscode-extensions.overlays.default
          ]
          ++ builtins.attrValues (import ./overlays { inherit inputs; });
        };

      HomeConfiguration =
        args:
        home-manager.lib.homeManagerConfiguration {
          modules = [
            (import ./hosts)
            (import ./modules)
          ];
          extraSpecialArgs = {
            inherit self inputs outputs;
          }
          // args.extraSpecialArgs;
          pkgs = pkgsForSystem (args.system or "x86_64-linux") nixpkgs;
        };
    in
    {
      formatter = forEachSystem (s: nixpkgs.legacyPackages.${s}.nixfmt);

      packages = forEachSystem (_: {
        homeConfigurations = {
          "luna.shorty" = HomeConfiguration {
            extraSpecialArgs = {
              hostname = "luna";
              username = "shorty";
              fullName = "Jordy Schreuders";
              email = "3071062+99linesofcode@users.noreply.github.com";
              role = "workstation";
            };
          };
          # TODO: dedicated SSH keys and server role configuration
          "mars.shorty" = HomeConfiguration {
            extraSpecialArgs = {
              hostname = "mars";
              username = "shorty";
              fullName = "Jordy Schreuders";
              email = "3071062+99linesofcode@users.noreply.github.com";
              role = "server";
            };
          };
        };
      });
    };
}
