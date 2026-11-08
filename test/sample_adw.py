#!/usr/bin/env python3
"""色の当たり方を見るための libadwaita の見本の窓。test/shoot.sh から使う。"""
import os

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
from gi.repository import Adw, GLib, Graphene, Gtk  # noqa: E402


def build(app):
    win = Adw.ApplicationWindow(application=app, default_width=760, default_height=480)
    split = Adw.NavigationSplitView()

    side_list = Gtk.ListBox(css_classes=["navigation-sidebar"])
    for name in ["ホーム", "書類", "画像", "ゴミ箱"]:
        side_list.append(Gtk.Label(label=name, xalign=0, margin_start=8, margin_top=6, margin_bottom=6))
    side_list.select_row(side_list.get_row_at_index(0))
    side_page = Adw.ToolbarView()
    side_page.add_top_bar(Adw.HeaderBar())
    side_page.set_content(side_list)
    split.set_sidebar(Adw.NavigationPage(title="場所", child=side_page))

    box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, margin_top=18,
                  margin_bottom=18, margin_start=18, margin_end=18)
    box.append(Gtk.Entry(text="入力欄"))
    group = Adw.PreferencesGroup(title="設定")
    row = Adw.SwitchRow(title="切り替え", active=True)
    group.add(row)
    group.add(Adw.ActionRow(title="ふつうの行", subtitle="説明の文"))
    box.append(group)
    buttons = Gtk.Box(spacing=8)
    buttons.append(Gtk.Button(label="ふつう"))
    buttons.append(Gtk.Button(label="決定", css_classes=["suggested-action"]))
    buttons.append(Gtk.Button(label="削除", css_classes=["destructive-action"]))
    box.append(buttons)
    box.append(Gtk.CheckButton(label="チェック", active=True))
    box.append(Gtk.LevelBar(value=0.6))

    content = Adw.ToolbarView()
    content.add_top_bar(Adw.HeaderBar())
    content.set_content(box)
    split.set_content(Adw.NavigationPage(title="見本", child=content))
    win.set_content(split)
    win.present()
    shot = os.environ.get("SHOT")
    if shot:
        GLib.timeout_add(1500, save_png, win, shot, app)


def save_png(win, path, app):
    """窓を自分で描いて PNG に書き出し、終わる（GTK4 の broadway はブラウザで撮れないため）。"""
    paintable = Gtk.WidgetPaintable(widget=win)
    w, h = win.get_width(), win.get_height()
    snap = Gtk.Snapshot()
    paintable.snapshot(snap, w, h)
    node = snap.to_node()
    renderer = win.get_native().get_renderer()
    texture = renderer.render_texture(node, Graphene.Rect().init(0, 0, w, h))
    texture.save_to_png(path)
    app.quit()
    return False


app = Adw.Application(application_id="dev.moomA.GtkTintSample")
app.connect("activate", build)
app.run()
