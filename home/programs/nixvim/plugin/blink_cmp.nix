{
  plugins.blink-cmp = {
    enable = true;
    settings = {
      keymap = {
        preset = "enter";

        "<Tab>" = [ "show" "fallback" ];
        "<C-j>" = [ "snippet_forward" "fallback" ];
        "<C-k>" = [ "snippet_backward" "fallback" ];
      };
      completion = {
        menu = {
          auto_show = false;
        };
        documentation = {
          auto_show = true;
          auto_show_delay_ms = 1000;
        };
        ghost_text = {
          enabled = true;
          show_without_selection = true;
        };
      };
      signature = {
        enabled = true;
      };
      sources = {
        default = [ "lsp" "path" "snippets" "buffer" ];
      };
    };
  };
}
