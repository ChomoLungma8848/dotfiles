{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        ms-ceintl.vscode-language-pack-ja
        ms-vsliveshare.vsliveshare
      ];
      userSettings = {
        "locale" = "ja";
      };
    };
  };
}
