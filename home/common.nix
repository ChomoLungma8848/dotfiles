{ pkgs, inputs, ... }:
{
  imports = [
    ./programs/zsh.nix
    ./programs/nixvim/nixvim.nix
    ./programs/git.nix
    ./programs/starship.nix
    ./programs/emacs
  ];

  home = rec {
    stateVersion = "25.11";
    username = "chomo";
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      bat
      eza
      ripgrep
      gh
      ghq
      lazygit
      fzf
      codex
      go
      jq
      nixfmt
      inputs.graftx.packages.${pkgs.system}.default
      tealdeer
      btop
    ];
    sessionPath = [ "$HOME/go/bin" ];
    sessionVariables = {
      CLAUDE_CODE_NEW_INIT = 1;
    };
  };

  programs.home-manager.enable = true;
}
