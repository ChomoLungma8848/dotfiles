{
  plugins.lsp = {
    enable = true;
    servers = {
      gopls = { enable = true; };
      nixd = { enable = true; };
    };
  };
}
