# Hyprland のディスプレイ制御。
#
#   hypr-display cycle : Windows の Win+P 相当。
#                        拡張 → 複製 → 内蔵のみ → 外部のみ を巡回する
#   hypr-display flip  : モニターの左右の並び順を反転する
#                        （物理的にモニターを置き換えたとき用）
#
# モニター名は設定に書かず実行時に取得するため、別環境でもそのまま動く。
#
# 状態は $XDG_RUNTIME_DIR (tmpfs) に置くセッション限りのもので、再ログインすると
# Hyprland 設定どおりの既定配置に戻る。実行時に変えられる状態は Nix の宣言的管理に
# 乗らないため、永続化せず揮発させることで「Nix 設定 = 常に真」を保つ。
#
# どの操作も「hyprctl reload で設定どおりに戻してから状態を組み立て直す」形にしている。
# これにより直前の状態に依存せず結果が一意に決まり、解像度・スケールの権威は
# Hyprland 設定(Nix 側の monitor 定義)に残る。
#
# Hyprland セッション内でのみ意味を持つため、hyprctl と noctalia は PATH 上にある前提で呼ぶ。

state_file="${XDG_RUNTIME_DIR:-/tmp}/hypr-display"
modes=(extend mirror internal external)

notify() {
  noctalia msg notification-show "ディスプレイ" "$1" >/dev/null 2>&1 || true
}

label() {
  case "$1" in
    extend) echo "拡張" ;;
    mirror) echo "複製" ;;
    internal) echo "内蔵モニターのみ" ;;
    external) echo "外部モニターのみ" ;;
    *) echo "$1" ;;
  esac
}

# 接続中(無効化中を含む)の全モニターを内蔵と外部に振り分ける
classify_monitors() {
  local m
  internal=()
  external=()
  while read -r m; do
    case "$m" in
      eDP-* | LVDS-* | DSI-*) internal+=("$m") ;;
      *) external+=("$m") ;;
    esac
  done < <(hyprctl -j monitors all | jq -r '.[].name')
}

# 有効なモニターを x 昇順に取り、逆順に左から詰め直す。
# 解像度・リフレッシュレート・スケールは現在値をそのまま渡し、位置だけを変える。
# 幅は transform(90/270 度回転)を考慮した論理幅で算出する。
apply_flip() {
  local entries=() e name mode scale width x=0
  mapfile -t entries < <(hyprctl -j monitors | jq -r '
    [ .[] | {
        name: .name,
        x: .x,
        mode: "\(.width)x\(.height)@\(.refreshRate)",
        scale: .scale,
        width: (if (.transform % 2) == 1 then (.height / .scale) else (.width / .scale) end)
      } ]
    | sort_by(.x) | reverse
    | .[] | "\(.name) \(.mode) \(.scale) \(.width | round)"
  ')
  # 1 枚だけのときは並び順という概念がないので何もしない
  [ "${#entries[@]}" -ge 2 ] || return 0
  for e in "${entries[@]}"; do
    read -r name mode scale width <<<"$e"
    hyprctl keyword monitor "$name,$mode,${x}x0,$scale" >/dev/null
    x=$((x + width))
  done
}

# 状態(モード・反転の有無)から実際のモニター構成を組み立てる
apply_state() {
  local m
  hyprctl reload >/dev/null

  case "$mode" in
    extend) ;;
    mirror)
      for m in "${external[@]}"; do
        hyprctl keyword monitor "$m,preferred,auto,auto,mirror,${internal[0]}" >/dev/null
      done
      ;;
    internal)
      for m in "${external[@]}"; do
        hyprctl keyword monitor "$m,disable" >/dev/null
      done
      ;;
    external)
      for m in "${internal[@]}"; do
        hyprctl keyword monitor "$m,disable" >/dev/null
      done
      ;;
  esac

  # 複製中は全モニターが同じ位置に重なるため、並び順の反転は意味を持たない
  if [ "$flipped" = "1" ] && [ "$mode" != "mirror" ]; then
    apply_flip
  fi

  printf 'mode=%s\nflipped=%s\n' "$mode" "$flipped" >"$state_file"
}

# 状態ファイルを読む。欠けている・壊れている場合は既定値に倒す。
load_state() {
  local i
  mode=""
  flipped=""
  if [ -r "$state_file" ]; then
    mode=$(sed -n 's/^mode=//p' "$state_file" | head -1)
    flipped=$(sed -n 's/^flipped=//p' "$state_file" | head -1)
  fi
  for i in "${modes[@]}"; do
    [ "$i" = "$mode" ] && return 0
  done
  mode="${modes[0]}"
  [ "$flipped" = "1" ] || flipped=0
}

case "${1:-}" in
  cycle)
    load_state
    classify_monitors
    if [ "${#external[@]}" -eq 0 ]; then
      notify "外部モニターが接続されていません"
      exit 0
    fi
    if [ "${#internal[@]}" -eq 0 ]; then
      notify "内蔵モニターが見つかりません"
      exit 0
    fi
    # 現在のモードの次へ進める
    for i in "${!modes[@]}"; do
      if [ "${modes[$i]}" = "$mode" ]; then
        mode="${modes[$(((i + 1) % ${#modes[@]}))]}"
        break
      fi
    done
    apply_state
    notify "$(label "$mode")"
    ;;
  flip)
    load_state
    classify_monitors
    if [ "$flipped" = "1" ]; then flipped=0; else flipped=1; fi
    apply_state
    if [ "$flipped" = "1" ]; then
      notify "並び順を反転しました"
    else
      notify "並び順を既定に戻しました"
    fi
    ;;
  *)
    echo "usage: hypr-display <cycle|flip>" >&2
    exit 2
    ;;
esac
