{ pkgs, inputs, ... }:
{
  imports = [
    ./programs/zsh.nix
    # ./programs/neovim.nix
    ./programs/nixvim/nixvim.nix
    ./programs/git.nix
    ./programs/starship.nix
  ];

  home = {
    stateVersion = "25.11";
    packages = with pkgs; [
      bat
      bottom
      eza
      httpie
      pingu
      pokemon-colorscripts
      ripgrep
      # git      # programs.git.enable = true で管理
      # starship # programs.starship.enable = true で管理
      # zsh      # programs.zsh.enable = true で管理
      gh
      ghq
      lazygit
      fzf
      codex
      go
      jq
      nixfmt
      wl-clipboard
      inputs.graftx.packages.${pkgs.system}.default
    ];
    sessionPath = [ "$HOME/go/bin" ];
    sessionVariables = {
      CLAUDE_CODE_NEW_INIT = 1;
    };
  };

  programs.home-manager.enable = true;
}
