{ pkgs, ... }:
let
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
{
  programs.emacs = {
    enable = true;
    extraPackages =
      epkgs: with epkgs; [
        leaf
        leaf-convert
        doom-themes
        doom-modeline
        org-roam
        org-pomodoro
        vertico
        orderless
        which-key
        (epkgs.melpaBuild {
          pname = "nskk";
          version = "0.2.1";
          src = sources.nskk.src;
          files = ''("src/*.el")'';
          ignoreCompilationError = false;
        })
      ];
    extraConfig = builtins.readFile ./init.el;
  };
}
