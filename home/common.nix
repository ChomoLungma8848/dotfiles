{
  pkgs,
  inputs,
  system,
  ...
}:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./programs/fish.nix
    ./programs/nixvim/nixvim.nix
    ./programs/git.nix
    ./programs/starship.nix
    ./programs/emacs
    ./programs/zoxide.nix
    ./programs/direnv.nix
    ./programs/auto-commit.nix
    ./programs/claude
  ];

  home = rec {
    stateVersion = "25.11";
    username = "chomo";
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      bat
      eza
      ripgrep
      fd
      gh
      ghq
      lazygit
      fzf
      jq
      nixfmt
      prettier
      inputs.graftx.packages.${system}.default
      inputs.llm-agents.packages.${system}.claude-code
      inputs.llm-agents.packages.${system}.codex
      tealdeer
      btop
      docker-compose
      lazydocker
      python3
      uv
      hunk
    ];
  };

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nix;
    settings = {
      extra-substituters = [ "https://cache.numtide.com" ];
      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };
  };

  programs.home-manager.enable = true;
}
