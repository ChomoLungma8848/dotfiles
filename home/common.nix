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
      claude-code
      go
      jq
      nixfmt
      inputs.graftx.packages.${system}.default
      tealdeer
      btop
    ];
    sessionPath = [ "$HOME/go/bin" ];
    sessionVariables = {
      CLAUDE_CODE_NEW_INIT = 1;
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;
}
