inputs: {
  allowUnfreePredicate =
    pkg:
    builtins.elem (inputs.nixpkgs.lib.getName pkg) [
      "claude"
      "google-chrome"
      "discord"
      "vscode"
      "antigravity"
      "vscode-extension-ms-vsliveshare-vsliveshare"
    ];
  overlays = [ inputs.nix-claude-code.overlays.default ];
}
