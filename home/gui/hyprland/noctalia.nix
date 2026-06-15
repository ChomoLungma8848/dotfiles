{ pkgs, ... }:
{
  home.packages = with pkgs; [
    noctalia-qs
  ];

  programs.noctalia-shell = {
    enable = true;
  };
}
