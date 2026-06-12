{
  keymaps = [
    {
      mode = "i";
      key = "jj";
      action = "<esc>";
    }

    # lsp
    # {
    #   diagnostic = {
    #     "gK" = "open_float";
    #   };
    #   lspBuf = {
    #     "K" = "hover";
    #     "gd" = "definition";
    #     "gn" = "rename";
    #     "ga" = "code_action";
    #     "gr" = "references";
    #   };
    # };

    # pantran
    {
      mode = "v";
      key = "<leader>tr";
      action = "<cmd>'<,'>Pantran<CR>";
    }
  ];
}
