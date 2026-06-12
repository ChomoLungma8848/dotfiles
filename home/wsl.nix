{ ... }:
{
  imports = [
    ./common.nix
  ];

  home = rec {
    username = "nixos";
    homeDirectory = "/home/${username}";
    sessionVariables = {
      WAYLAND_DISPLAY = "/mnt/wslg/runtime-dir/wayland-0";
    };
  };
}
