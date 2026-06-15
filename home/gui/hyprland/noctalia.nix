{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fastfetch
  ];

  programs.noctalia-shell = {
    enable = true;
  };

  home.file.".cache/noctalia/wallpapers.json" = {
    text = builtins.toJSON{
      wallpapers = {
        "DP-1" = "../../../wallpaper/wallpaper-1.png";
      };
    };
  };
}
