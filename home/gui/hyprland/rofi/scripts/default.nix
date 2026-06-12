{ pkgs }:
let
  importScript = name: import ./${name}.nix { inherit pkgs; };
in
builtins.listToAttrs (map (name: {
  name = "rofi-${name}";
  value = importScript name;
}) [ "hub" "wifi" "bluetooth" "files" "colorpicker" "nerd" "power" ])
