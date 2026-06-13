{
  programs = {
    nixvim = {
      enable = true;
      viAlias = true;

      imports = [
        ./global.nix
        ./opt.nix
        ./keymap.nix
        ./colorscheme.nix

        ./plugin/lsp.nix
        ./plugin/pantran.nix
        ./plugin/snacks.nix
        ./plugin/noice.nix
      ];

    };
  };
}
