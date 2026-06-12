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
    graftx.url = "github:myuron/graftx";
  };

  outputs = inputs: {
    nixosConfigurations = {
      # ネイティブ NixOS (GUI) 環境
      nixos = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./os/gui.nix
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
    };

    homeConfigurations = {
      # ネイティブ NixOS (GUI) 環境: chomo ユーザー
      home = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
          config.allowUnfreePredicate =
            pkg:
            builtins.elem (inputs.nixpkgs.lib.getName pkg) [
              "claude"
              "google-chrome"
              "discord"
              "vscode"
              "antigravity"
              "vscode-extension-ms-vsliveshare-vsliveshare"
            ];
          overlays = [ inputs.nix-claude-code.overlays.default ];
        };
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = [
          ./home/gui.nix
          inputs.nixvim.homeModules.nixvim
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
          config.allowUnfreePredicate =
            pkg:
            builtins.elem (inputs.nixpkgs.lib.getName pkg) [
              "claude"
            ];
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
  };
}
