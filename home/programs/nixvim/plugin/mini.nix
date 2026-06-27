{
  plugins = {
    mini-surround = {
      enable = true;
    };
    mini-pairs = {
      enable = true;
    };
    mini-icons = {
      enable = true;
    };
    mini-hipatterns = {
      enable = true;
      settings = {
        highlighters = {
          hex_color = {
            __raw = "require('mini.hipatterns').gen_highlighter.hex_color()";
          };
        };
      };
    };
  };
}
