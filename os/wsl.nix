{ pkgs, ... }:
{
  imports = [
    ./common.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = "chomo";

  users.users.chomo = {
    shell = pkgs.zsh;
  };
}
