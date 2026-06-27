{ ... }:
{
  imports = [
    ./common.nix
  ];

  home.sessionVariables = {
    WAYLAND_DISPLAY = "/mnt/wslg/runtime-dir/wayland-0";
  };
}
