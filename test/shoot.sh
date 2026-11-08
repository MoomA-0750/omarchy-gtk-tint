#!/bin/bash
# 見本の窓を GTK の broadway（画面の要らない描き先）で開いて撮る。
#   test/shoot.sh <colors.toml> <出力の png の頭> [--plain]
# --plain を付けると色を当てない素の Adwaita を撮る（比べる用）。
# chromium が要る。
set -euo pipefail

here="$(cd "$(dirname "$0")/.." && pwd)"
colors="$1"
prefix="$2"
plain="${3:-}"

work=$(mktemp -d)
trap 'kill $(jobs -p) 2>/dev/null || true; wait 2>/dev/null || true; rm -rf "$work"' EXIT

mode=$(awk -F'"' '/^mode *=/ {print $2}' "$colors")
[[ -n $mode ]] || mode=dark

export XDG_CONFIG_HOME="$work/config"
mkdir -p "$XDG_CONFIG_HOME/gtk-4.0" "$XDG_CONFIG_HOME/gtk-3.0"
if [[ $plain != "--plain" ]]; then
  "$here/bin/omarchy-gtk-tint" "$colors" "$XDG_CONFIG_HOME/omarchy/gtk-tint"
  echo "@import url(\"file://$XDG_CONFIG_HOME/omarchy/gtk-tint/gtk4.css\");" >"$XDG_CONFIG_HOME/gtk-4.0/gtk.css"
  echo "@import url(\"file://$XDG_CONFIG_HOME/omarchy/gtk-tint/gtk3.css\");" >"$XDG_CONFIG_HOME/gtk-3.0/gtk.css"
fi

if [[ $mode == light ]]; then
  export ADW_DEBUG_COLOR_SCHEME=prefer-light
  gtk3_theme=Adwaita
else
  export ADW_DEBUG_COLOR_SCHEME=prefer-dark
  gtk3_theme=Adwaita:dark
fi

shoot() {
  local port="$1" out="$2"
  chromium --headless --no-sandbox --disable-gpu --hide-scrollbars --window-size=800,540 \
    --timeout=4000 --screenshot="$out" "http://127.0.0.1:$port/" >/dev/null 2>&1
}

gtk4-broadwayd :17 >/dev/null 2>&1 &
sleep 1
# GTK4 の broadway はブラウザで撮れないので、見本の窓に自分で書き出させる
SHOT="${prefix}-gtk4.png" GDK_BACKEND=broadway BROADWAY_DISPLAY=:17 \
  timeout 20 python3 "$here/test/sample_adw.py" 2>"$work/adw.log"
grep -i "warn\|error" "$work/adw.log" | head -5 || true

broadwayd :18 >/dev/null 2>&1 &
sleep 1
GDK_BACKEND=broadway BROADWAY_DISPLAY=:18 GTK_THEME=$gtk3_theme python3 "$here/test/sample_gtk3.py" 2>"$work/gtk3.log" &
sleep 2
shoot 8098 "${prefix}-gtk3.png"
grep -i "warn\|error" "$work/gtk3.log" | head -5 || true
