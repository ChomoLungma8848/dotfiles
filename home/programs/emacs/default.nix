{ pkgs, inputs, ... }:
let
  # sources = pkgs.callPackage ../../_sources/generated.nix { };
  tangle = inputs.org-babel.lib.tangleOrgBabel { languages = [ "emacs-lisp" ]; };
in
{
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      modus-themes
      vertico
      vertico-posframe
      marginalia
      orderless
      evil
    ];
  };

  home.file.".emacs.d/init.el".text = tangle (builtins.readFile ./init.org);
}
