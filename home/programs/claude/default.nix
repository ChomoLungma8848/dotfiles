{ config, lib, ... }:
let
  dotfiles = "${config.home.homeDirectory}/ghq/github.com/ChomoLungma8848/dotfiles";
  claudeDir = "${dotfiles}/home/programs/claude";
in
{
  home.activation.linkClaudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ln -sfn "${claudeDir}/skills" "$HOME/.claude/skills"
  '';
}
