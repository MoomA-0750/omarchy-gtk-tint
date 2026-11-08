# omarchy-gtk-tint

Omarchy のテーマの色を GTK のアプリにも当てる。

Omarchy はテーマを切り替えると、端末や VS Code などには `colors.toml` の色を全部渡すが、GTK のアプリには「Adwaita の明るい版か暗い版か」とアイコンしか渡さない（`omarchy-theme-set-gnome`）。そのため Nautilus などの GTK のアプリだけ、アクセント色も背景色も素の Adwaita のままになる。Qt のアプリも `QT_QPA_PLATFORMTHEME=gtk3` で GTK の真似をするので同じ。

これを入れると、テーマを切り替えるたびに `colors.toml` から GTK 用の CSS を作り、GTK のアプリが起動時に読む `gtk.css` から読ませる。

## 入れ方

```sh
./install.sh
```

すること:

- `~/.local/bin/omarchy-gtk-tint` を置く
- テーマを切り替えたときに動くフック `~/.config/omarchy/hooks/theme-set.d/50-gtk-tint` を置く
- 今のテーマで `~/.config/omarchy/gtk-tint/gtk4.css` と `gtk3.css` を作る
- `~/.config/gtk-4.0/gtk.css` と `~/.config/gtk-3.0/gtk.css` の先頭に、それを読む `@import` を目印の行で囲んで足す（ほかの中身はそのまま残す）

外すときは `./install.sh --remove`。足した行と作ったファイルだけを消す。

## 効くところ・効かないところ

- **GTK4 / libadwaita のアプリ**（Nautilus、GNOME の付属アプリなど）: libadwaita の色の名前（`accent_bg_color`、`window_bg_color`、`view_bg_color`、`headerbar_bg_color`、`sidebar_bg_color`、`card_bg_color` など）を上書きするので、ほぼ全体がテーマの色になる
- **GTK3 のアプリ**: 古い色の名前の上書きに加えて、窓・見出し・入力欄・一覧・選択・チェック欄・決定ボタンなどを直接塗っている。独自の CSS を持つアプリでは効かない部分が残る
- **開いているアプリ**: GTK は起動時に `gtk.css` を読むので、テーマを切り替えたあとは開き直すまで色が変わらない
- **Qt のアプリ**: 試していない

アクセント色や赤などの上に載せる文字は、テーマの背景色と文字色のうち、その色との差が大きい方を選んでいる。

## 色の対応

| GTK | colors.toml |
|---|---|
| アクセント | `accent` |
| 窓の地 | `background` |
| 一覧・入力欄・横の欄 | `dark_background` |
| 見出しの帯・カード・ダイアログ・ポップオーバー | `lighter_background` |
| 境目の線 | `muted` |
| 削除・エラー / 成功 / 警告 | `red` / `green` / `yellow` |

## 試し方

```sh
test/shoot.sh <colors.toml> /tmp/out/名前          # 色を当てた見本の窓を撮る
test/shoot.sh <colors.toml> /tmp/out/plain --plain # 比べる用の素の Adwaita
```

GTK の broadway（画面の要らない描き先）で見本の窓（`test/sample_adw.py`、`test/sample_gtk3.py`）を開いて PNG にする。要るのは `gtk4-broadwayd`、`broadwayd`、python の GTK3・GTK4・libadwaita、`chromium`。Omarchy が入っていない PC でも試せる。Omarchy の `themes/*/colors.toml` の暗いテーマ（catppuccin、tokyo-night）と明るいテーマ（flexoki-light）で確かめた。
