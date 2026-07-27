{
  config,
  lib,
  pkgs,
  ...
}:
# 構造化オプション programs.claude-code.* を意図的に使っていない。
# あれは ~/.claude/settings.json を nix store への read-only symlink にするが、
# Claude Code は /model や /config などの操作で settings.json を実行時に書き換えるため、
# read-only だと権限エラーで機能が壊れる (anthropics/claude-code#52525 #15786 #3575)。
# よって settings.json は「実ファイルを保ちつつ dotfiles 側の宣言キーだけをマージする」方式にし、
# 宣言内容自体は Nix 式で書いて pkgs.formats.json に JSON 化させる。
let
  dotfiles = "${config.home.homeDirectory}/ghq/github.com/ChomoLungma8848/dotfiles";
  claudeDir = "${dotfiles}/home/programs/claude";

  # このディレクトリ直下のディレクトリを全て ~/.claude/<名前> へ symlink する。
  # agents/ commands/ などを後から足しても、ここを直さずに対象へ入る。
  # ディレクトリの symlink は Write/Edit ツールの拒否対象外なので、
  # ~/.claude 側から直接編集しても dotfiles の実体に書き込まれる。
  linkedDirs = lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.));

  # ~/.claude/CLAUDE.md は symlink にできない。
  # Write/Edit ツールは「ファイルの symlink」への書き込みを拒否するため、
  # 実体は dotfiles に置き、~/.claude 側は @import 1 行の実ファイルにする。
  claudeMd = pkgs.writeText "claude-md" ''
    <!-- home-manager が生成するファイル。ここを編集しても switch で上書きされる。
         実体は下の @import 先を編集すること。 -->

    @${claudeDir}/CLAUDE.user.md
  '';

  # settings.json のうち dotfiles で宣言するキーだけを持つ断片。
  # ここに書いたキーは switch のたびに強制的に適用される (dotfiles が勝つ)。
  # 逆に、Claude Code が実行時に書き込むキー (model / theme / effortLevel /
  # tui / teammateMode など) は「あえて書かない」。書くと TUI での変更が
  # 次の switch で巻き戻る。マシン間で揃えたくなったキーだけをここへ昇格させる。
  settingsFragment = (pkgs.formats.json { }).generate "claude-settings-fragment.json" {
    language = "japanese";
    env = {
      CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
      CLAUDE_CODE_NEW_INIT = "1";
    };
    permissions.defaultMode = "auto";
    autoMemoryEnabled = false; 
    autoCompactEnabled = false;
    teammateMode = "auto";
    respectGitIgnore = false;
    remoteControlAtStartup = true;
    agentPushNotifEnabled = true;
    hooks.Stop = [
      {
        hooks = [
          {
            type = "command";
            command = ''sh "$HOME/.claude/hooks/format-md.sh"'';
          }
        ];
      }
    ];
    enabledPlugins = {
      "skill-creator@claude-plugins-official" = true;
      "commit@cc-utility" = true;
      "handoff@cc-utility" = true;
    };
    tui = "fullscreen";
    theme = "dark";
  };
in
{
  home.activation.claude = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/.claude"

    ${lib.concatMapStringsSep "\n" (dir: ''
      # 実体のディレクトリが居座っていると ln -sfn がその中にリンクを作ってしまうため退避する
      if [[ -e "$HOME/.claude/${dir}" && ! -L "$HOME/.claude/${dir}" ]]; then
        warnEcho "~/.claude/${dir} が実体のため ~/.claude/${dir}.bak へ退避します"
        run mv "$HOME/.claude/${dir}" "$HOME/.claude/${dir}.bak"
      fi
      run ln -sfn "${claudeDir}/${dir}" "$HOME/.claude/${dir}"
    '') linkedDirs}

    run install -m 644 ${claudeMd} "$HOME/.claude/CLAUDE.md"

    # settings.json は実ファイルのまま、宣言キーだけを右辺優先でマージする。
    # 断片に無いキー (Claude Code が実行時に書いたもの) はそのまま残る。
    if [[ -v DRY_RUN ]]; then
      echo "merge ${settingsFragment} into $HOME/.claude/settings.json"
    else
      claudeSettings="$HOME/.claude/settings.json"
      if [[ -f "$claudeSettings" ]]; then
        ${lib.getExe pkgs.jq} -s '.[0] * .[1]' "$claudeSettings" ${settingsFragment} \
          > "$claudeSettings.new"
      else
        cp ${settingsFragment} "$claudeSettings.new"
      fi
      mv "$claudeSettings.new" "$claudeSettings"
      chmod 644 "$claudeSettings"
    fi
  '';
}
