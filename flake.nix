{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-claude-code = {
      url = "github:ryoppippi/nix-claude-code";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    graftx.url = "github:myuron/graftx";
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      # nixpkgs の allowUnfree / overlays 設定を一元管理
      # standalone homeConfigurations と #install NixOS モジュール両方から参照する
      nixpkgsSettings = import ./lib/nixpkgs-settings.nix inputs;
    in
    {
      nixosConfigurations = {
        # ネイティブ NixOS (GUI) 環境（#install でセットアップしたマシンの再ビルド用）
        # disko + generic.nix で hardware-configuration.nix を不要にしているため pure 評価可能:
        #   sudo nixos-rebuild switch --flake .#nixos
        nixos = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./os/gui.nix
            # disko によるディスク宣言（fileSystems.* を自動生成）
            inputs.disko.nixosModules.disko
            ./os/disk-config.nix
            # 汎用ハードウェアモジュール（hardware-configuration.nix の代替）
            ./os/hardware/generic.nix
          ];
        };

        # WSL 環境
        wsl = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./os/wsl.nix
            inputs.nixos-wsl.nixosModules.default
            inputs.nixos-vscode-server.nixosModules.default
          ];
        };

        # 新規マシンへの一発インストール用プロファイル（pure 評価可能 / --impure 不要）
        # disko でディスクを宣言、home-manager を NixOS モジュールとして統合。
        # 使い方:
        #   nix run github:ChomoLungma8848/dotfiles#install
        # または手動:
        #   nix run github:nix-community/disko -- --mode destroy,format,mount --flake github:ChomoLungma8848/dotfiles#install
        #   nixos-install --flake github:ChomoLungma8848/dotfiles#install --no-root-passwd
        install = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./os/gui.nix
            # disko によるディスク宣言（fileSystems.* を自動生成）
            inputs.disko.nixosModules.disko
            ./os/disk-config.nix
            # 汎用ハードウェアモジュール（hardware-configuration.nix の代替）
            ./os/hardware/generic.nix
            # home-manager を NixOS モジュールとして統合
            inputs.home-manager.nixosModules.home-manager
            {
              # useGlobalPkgs = true のとき nixpkgs.* はシステム側で設定する必要がある
              # （home-manager.users.*.nixpkgs.* は評価エラーになる）
              nixpkgs.config.allowUnfreePredicate = nixpkgsSettings.allowUnfreePredicate;
              nixpkgs.overlays = nixpkgsSettings.overlays;

              # 初期パスワード（#install 専用。既存 #nixos には影響しない）
              # 初回ログイン後に passwd コマンドで変更すること
              users.users.chomo.initialPassword = "admin";

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # graftx 等が inputs を参照するため必須
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.chomo =
                # pkgs は useGlobalPkgs = true によりシステムの nixpkgs（overlay 済み）
                { pkgs, ... }:
                {
                  imports = [
                    ./home/gui.nix
                    inputs.nixvim.homeModules.nixvim
                  ];
                  # overlay 由来の claude-code パッケージ（pkgs = overlay 適用済みシステム pkgs）
                  programs.claude-code = {
                    enable = true;
                    package = pkgs.claude-code;
                  };
                };
            }
          ];
        };
      };

      homeConfigurations = {
        # ネイティブ NixOS (GUI) 環境: chomo ユーザー（standalone; 既存機で home-manager switch に使用）
        home = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            system = "x86_64-linux";
            config.allowUnfreePredicate = nixpkgsSettings.allowUnfreePredicate;
            overlays = nixpkgsSettings.overlays;
          };
          extraSpecialArgs = {
            inherit inputs;
          };
          modules = [
            ./home/gui.nix
            inputs.nixvim.homeModules.nixvim
            inputs.noctalia.homeModules.default
            (
              { pkgs, ... }:
              {
                programs.claude-code = {
                  enable = true;
                  package = pkgs.claude-code;
                };
              }
            )
          ];
        };

        # WSL 環境: nixos ユーザー
        wsl = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            system = "x86_64-linux";
            config.allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) [ "claude" ];
            overlays = [ inputs.nix-claude-code.overlays.default ];
          };
          extraSpecialArgs = {
            inherit inputs;
          };
          modules = [
            ./home/wsl.nix
            (
              { pkgs, ... }:
              {
                programs.claude-code = {
                  enable = true;
                  package = pkgs.claude-code;
                };
              }
            )
          ];
        };
      };

      # 新規マシンへの一発インストールラッパー
      # ISO 起動後 root で: nix run github:ChomoLungma8848/dotfiles#install
      # ※ disk-config.nix の device を実機のディスク名に合わせてから push すること
      apps.x86_64-linux.install =
        let
          pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        in
        {
          type = "app";
          program = "${
            pkgs.writeShellApplication {
              name = "install";
              runtimeInputs = [
                inputs.disko.packages.x86_64-linux.disko
              ];
              text = ''
                FLAKE="github:ChomoLungma8848/dotfiles#install"
                echo ">>> disko: ディスクのパーティション・フォーマット・マウント"
                disko --mode destroy,format,mount --flake "$FLAKE"
                echo ">>> nixos-install: システム + home-manager のビルドとインストール"
                nixos-install --flake "$FLAKE" --no-root-passwd
                echo ">>> 完了。reboot 後に chomo / admin でログインし、passwd で変更してください。"
              '';
            }
          }/bin/install";
        };
    };
}
