{
  pkgs,
  inputs,
  system,
  ...
}:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./programs/zsh.nix
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
      claude-code
      codex
      jq
      nixfmt
      inputs.graftx.packages.${system}.default
      tealdeer
      btop
      docker-compose
      lazydocker
      python3
    ];
  };

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;
}
