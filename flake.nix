{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    graftx.url = "github:myuron/graftx";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      treefmt-nix,
      disko,
      home-manager,
      nixos-wsl,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        formatter = treefmt-nix.lib.mkWrapper pkgs {
          projectRootFile = "flake.nix";
          programs = {
            nixfmt.enable = true;
          };
        };

        apps = {
          install = {
            type = "app";
            program = "${
              pkgs.writeShellApplication {
                name = "install";
                runtimeInputs = [ disko.packages.${system}.disko ];
                text = ''
                  FLAKE="github:ChomoLungma8848/dotfiles#nixos"
                  echo ">>> disko: ディスクのパーティション・フォーマット・マウント"
                  disko --mode destroy,format,mount --flake "$FLAKE"
                  echo ">>> nixos-install: NixOS システムのビルドとインストール"
                  nixos-install --flake "$FLAKE" --no-root-passwd
                  echo ">>> 完了。reboot 後に chomo / admin でログインし、passwd で変更してください。"
                  echo ">>> 続いてユーザー環境（dotfiles）を次の1コマンドで適用:"
                  echo ">>>   nix run home-manager -- switch --flake github:ChomoLungma8848/dotfiles#home"
                '';
              }
            }/bin/install";
          };
        };
      }
    )

    // {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./os/hardware/generic.nix
            disko.nixosModules.disko
            ./os/disk-config.nix
            ./os/gui.nix
            {
              users.users.chomo.initialPassword = "admin";
            }
          ];
        };

        wsl = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./os/wsl.nix
            nixos-wsl.nixosModules.default
          ];
        };
      };

      homeConfigurations = {
        home = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs system; };
          modules = [
            ./home/gui.nix
          ];
        };

        wsl = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs system; };
          modules = [
            ./home/wsl.nix
          ];
        };
      };
    };
}
