{
  description = "Home Manager configuration";

  # NOTE: nix release versions are manually kept in sync with nixos-config nixpkgs.url
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-24.11";
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

      system = "x86_64-linux";

      # pkgs = nixpkgs.legacyPackages.${system};

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
          pkgs = pkgsForSystem (args.system or system) nixpkgs;
        };
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;

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
    };
}
