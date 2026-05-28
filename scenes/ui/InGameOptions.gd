extends Control
class_name InGameOptions
# InGameOptions.gd
#
# Instantiated by HUD when the ⚙ button is pressed.
# Provides: Music volume, SFX volume, Fullscreen toggle,
#           Save Game, Return to Title Screen, Exit Game.

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build()

func _build() -> void:
	# ── Dimmed backdrop ──
	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.0, 0.0, 0.0, 0.55)
	add_child(backdrop)
	backdrop.gui_input.connect(func(_e): pass)  # swallow clicks outside panel

	# ── Centred panel ──
	var panel := PanelContainer.new()
	var vp := get_viewport().get_visible_rect().size
	panel.custom_minimum_size = Vector2(380, 0)
	panel.set_position(Vector2(vp.x / 2.0 - 190.0, vp.y / 2.0 - 240.0))
	panel.set_size(Vector2(380, 480))
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "⚙️  Options"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0))
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	# ── Music volume ──
	vbox.add_child(_section("🎵  Music Volume"))
	var music_slider := _make_slider(_db_to_linear(_get_bus_db("Music")))
	music_slider.value_changed.connect(func(v): _set_bus_volume("Music", v))
	vbox.add_child(music_slider)

	# ── SFX volume ──
	vbox.add_child(_section("🔊  Sound Effects Volume"))
	var sfx_slider := _make_slider(_db_to_linear(_get_bus_db("SFX")))
	sfx_slider.value_changed.connect(func(v): _set_bus_volume("SFX", v))
	vbox.add_child(sfx_slider)

	# ── Fullscreen ──
	vbox.add_child(HSeparator.new())
	var fs_check := CheckButton.new()
	fs_check.text = "🖥️  Fullscreen"
	fs_check.button_pressed = \
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fs_check.toggled.connect(func(on):
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED))
	vbox.add_child(fs_check)

	vbox.add_child(HSeparator.new())

	# ── Save Game ──
	var btn_save := Button.new()
	btn_save.text = "💾  Save Game"
	btn_save.pressed.connect(_on_save)
	vbox.add_child(btn_save)

	# ── Return to Title ──
	var btn_title := Button.new()
	btn_title.text = "🏠  Return to Title Screen"
	btn_title.pressed.connect(_on_return_title)
	vbox.add_child(btn_title)

	# ── Exit Game ──
	var btn_exit := Button.new()
	btn_exit.text = "🚪  Exit Game"
	btn_exit.pressed.connect(func(): get_tree().quit())
	vbox.add_child(btn_exit)

	vbox.add_child(HSeparator.new())

	# ── Close ──
	var btn_close := Button.new()
	btn_close.text = "✕  Close"
	btn_close.pressed.connect(queue_free)
	vbox.add_child(btn_close)

# ── Actions ────────────────────────────────────────────────────────

func _on_save() -> void:
	GameState.save()
	# Brief feedback: flash the button text
	var btn := _find_btn("💾  Save Game")
	if btn:
		btn.text = "✔  Saved!"
		await get_tree().create_timer(1.5).timeout
		if is_instance_valid(btn):
			btn.text = "💾  Save Game"

func _on_return_title() -> void:
	GameState.save()   # auto-save before leaving
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")

func _find_btn(label: String) -> Button:
	for child in get_children():
		var result := _search_btn(child, label)
		if result:
			return result
	return null

func _search_btn(node: Node, label: String) -> Button:
	if node is Button and node.text == label:
		return node
	for c in node.get_children():
		var r := _search_btn(c, label)
		if r:
			return r
	return null

# ── Audio helpers ───────────────────────────────────────────────────

func _get_or_create_bus(bus_name: String) -> int:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		AudioServer.add_bus()
		idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, bus_name)
	return idx

func _get_bus_db(bus_name: String) -> float:
	return AudioServer.get_bus_volume_db(_get_or_create_bus(bus_name))

func _set_bus_volume(bus_name: String, linear: float) -> void:
	AudioServer.set_bus_volume_db(_get_or_create_bus(bus_name), linear_to_db(linear))

func _db_to_linear(db: float) -> float:
	return db_to_linear(db)

func _make_slider(initial: float) -> HSlider:
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step      = 0.05
	s.value     = initial
	return s

func _section(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(0.6, 0.85, 1.0))
	return lbl
