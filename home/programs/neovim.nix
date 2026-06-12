{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withPython3 = false;
    withRuby = false;
    extraPackages = with pkgs; [
      lua-language-server
      nil
      stylua
      nixfmt
      prettierd
    ];
  };
  home.file = {
    ".config/nvim" = {
      source = ./nvim;
    recursive = true;
  };
};

}
