#!/bin/bash
# omarchy-gtk-tint を入れる。何度実行しても同じ状態になる。
#   ./install.sh            入れる
#   ./install.sh --remove   外す（作った CSS と gtk.css に足した行を消す）
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
config="${XDG_CONFIG_HOME:-$HOME/.config}"
bin_dir="$HOME/.local/bin"
hook="$config/omarchy/hooks/theme-set.d/50-gtk-tint"
out_dir="$config/omarchy/gtk-tint"
begin="/* omarchy-gtk-tint begin */"
end="/* omarchy-gtk-tint end */"

remove_block() {
  local file="$1"
  [[ -f $file ]] || return 0
  awk -v b="$begin" -v e="$end" '$0 == b {skip = 1; next} $0 == e {skip = 0; next} !skip' "$file" >"$file.tmp"
  mv "$file.tmp" "$file"
}

add_block() {
  local file="$1" css="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  remove_block "$file"
  # CSS の @import はほかの規則より前に置かないと無視されるので、先頭に入れる
  { printf '%s\n@import url("file://%s");\n%s\n' "$begin" "$css" "$end"; cat "$file"; } >"$file.tmp"
  mv "$file.tmp" "$file"
}

if [[ ${1:-} == "--remove" ]]; then
  remove_block "$config/gtk-4.0/gtk.css"
  remove_block "$config/gtk-3.0/gtk.css"
  rm -f "$hook" "$bin_dir/omarchy-gtk-tint"
  rm -rf "$out_dir"
  echo "外しました。開いている GTK アプリは開き直すと元の色に戻ります。"
  exit 0
fi

mkdir -p "$bin_dir" "$(dirname "$hook")"
install -m 755 "$here/bin/omarchy-gtk-tint" "$bin_dir/omarchy-gtk-tint"
cat >"$hook" <<EOF
#!/bin/bash
# テーマを切り替えたら GTK の色の CSS を作り直す（omarchy-gtk-tint）
"$bin_dir/omarchy-gtk-tint"
EOF
chmod 755 "$hook"

"$bin_dir/omarchy-gtk-tint"
add_block "$config/gtk-4.0/gtk.css" "$out_dir/gtk4.css"
add_block "$config/gtk-3.0/gtk.css" "$out_dir/gtk3.css"
echo "入れました。GTK アプリを開き直すと今のテーマの色になります。"
