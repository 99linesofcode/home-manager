{
  description = "Home Manager configuration";

  # NOTE: nix release versions are manually kept in sync with nixos-config nixpkgs.url
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
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

      forEachSystem = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      pkgsForSystem =
        system: nixpkgsSource:
        import nixpkgsSource {
          overlays = [
            #NOTE: add your custom overlays here
          ];
          inherit system;
        };

      HomeConfiguration =
        args:
        home-manager.lib.homeManagerConfiguration {
          modules = [
            (import ./hosts)
            (import ./modules)
          ];
          extraSpecialArgs = {
            inherit (args) nixpkgs;
          } // args.extraSpecialArgs;
          pkgs = pkgsForSystem (args.system or "x86_64-linux") nixpkgs;
        };
    in
    {
      formatter = forEachSystem (s: nixpkgs.legacyPackages.${s}.nixfmt-rfc-style);

      legacyPackages = forEachSystem (s: {
        homeConfigurations = {
          "luna.shorty" = HomeConfiguration {
            extraSpecialArgs = {
              inherit inputs outputs;
              hostname = "luna";
              username = "shorty";
              fullName = "Jordy Schreuders";
              email = "3071062+99linesofcode@users.noreply.github.com";
              role = "workstation";
            };
          };
        };
      });
    };
}
