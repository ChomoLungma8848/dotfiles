{ ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$custom$directory$git_branch$git_status$nix_shell$character";

      custom.tmux = {
        command = "tmux display-message -p '#S'";
        when = ''test -n "$TMUX"'';
        format = "[\\[$output\\]]($style)";
        style = "green";
      };

      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = "@";
      };

      character = {
        success_symbol = "[>](green)";
        error_symbol = "[>](red)";
      };

      nix_shell = {
        format = "[$symbol]($style) ";
        symbol = "❄️";
      };

      line_break = {
        disable = true;
      };
    };
  };
}
