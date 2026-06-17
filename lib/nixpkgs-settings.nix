inputs: {
  allowUnfreePredicate =
    pkg:
    builtins.elem (inputs.nixpkgs.lib.getName pkg) [
      "claude"
      "google-chrome"
      "discord"
    ];
  overlays = [ inputs.nix-claude-code.overlays.default ];
}
