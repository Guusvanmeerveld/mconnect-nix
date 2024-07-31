{
  description = "Nixified mconnect";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
  }:
    {
      homeManagerModules = {
        default = import ./modules/home-manager.nix;
      };

      nixosModules = {
        default = import ./modules/nixos.nix;
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages = {
        mconnect = pkgs.callPackage ./package.nix {};
      };
    });
}
