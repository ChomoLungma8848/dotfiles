{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    org-babel.url = "github:emacs-twist/org-babel";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      treefmt-nix,
      disko,
      home-manager,
      nixos-wsl,
      org-babel,
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
          # archive/ は import グラフから外した未使用ファイル置き場。
          # 整形すると使っていないファイルが nix fmt のたびに差分を生むため除外する
          settings.global.excludes = [ "archive/**" ];
          programs = {
            nixfmt.enable = true; # Nix
            taplo.enable = true; # TOML
            stylua.enable = true; # Lua
            yamlfmt.enable = true; # YAML
            rumdl-format.enable = true; # Markdown
            biome = {
              # JSON。biome は JS/TS/CSS も扱うが、対象を JSON に限定して使う
              enable = true;
              formatCommand = "format";
              includes = [
                "*.json"
                "*.jsonc"
              ];
              # biome の既定はタブ。他のフォーマッタに合わせて 2 スペースにする
              settings.formatter = {
                indentStyle = "space";
                indentWidth = 2;
              };
            };
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
