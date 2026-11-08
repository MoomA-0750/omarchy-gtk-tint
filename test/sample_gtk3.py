#!/usr/bin/env python3
"""色の当たり方を見るための GTK3 の見本の窓。test/shoot.sh から使う。"""
import gi

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk  # noqa: E402

win = Gtk.Window(default_width=520, default_height=360)
header = Gtk.HeaderBar(title="GTK3 の見本", show_close_button=True)
win.set_titlebar(header)
box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10, margin=16)
box.pack_start(Gtk.Entry(text="入力欄"), False, False, 0)
store = Gtk.ListStore(str)
for name in ["一行目", "二行目（選択中）", "三行目"]:
    store.append([name])
tree = Gtk.TreeView(model=store)
tree.append_column(Gtk.TreeViewColumn("名前", Gtk.CellRendererText(), text=0))
tree.get_selection().select_path(Gtk.TreePath(1))
box.pack_start(tree, False, False, 0)
buttons = Gtk.Box(spacing=8)
buttons.pack_start(Gtk.Button(label="ふつう"), False, False, 0)
ok = Gtk.Button(label="決定")
ok.get_style_context().add_class("suggested-action")
buttons.pack_start(ok, False, False, 0)
box.pack_start(buttons, False, False, 0)
check = Gtk.CheckButton(label="チェック", active=True)
box.pack_start(check, False, False, 0)
win.add(box)
win.connect("destroy", Gtk.main_quit)
win.show_all()
Gtk.main()
