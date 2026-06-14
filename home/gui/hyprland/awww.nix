{ ... }:
let
  wallpaper = ./wallpaper-1.png;
in
{
  services.awww.enable = true;

  home.file.".config/hypr/scripts/awww-init.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      awww img "${wallpaper}" --transition-type fade --transition-duration 1
    '';
  };
}
