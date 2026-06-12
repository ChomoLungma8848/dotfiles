{ pkgs, ... }:
{
  imports = [
    ./common.nix
  ];

  services.vscode-server.enable = true;

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  users.users.nixos = {
    shell = pkgs.zsh;
  };
}
