extends Control
# TitleScreen.gd
# Attach to a Control node that covers the full screen.
# Autoload GameState and GameData must be set up before this scene is loaded.

const SAVE_SLOT_PATH := "user://sharc_save_slot_%d.json"
const MAX_SLOTS := 3

@onready var main_menu:     Control = $MainMenu
@onready var new_game_panel:  Control = $NewGamePanel
@onready var load_game_panel: Control = $LoadGamePanel
@onready var options_panel:   Control = $OptionsPanel

# ──────────────────────────────────────────
#  LIFECYCLE
# ──────────────────────────────────────────

func _ready() -> void:
	_build_main_menu()
	_build_new_game_panel()
	_build_load_game_panel()
	_build_options_panel()
	_show_panel(main_menu)


# ──────────────────────────────────────────
#  PANEL SWITCHER
# ──────────────────────────────────────────

func _show_panel(panel: Control) -> void:
	for p in [main_menu, new_game_panel, load_game_panel, options_panel]:
		p.visible = (p == panel)


# ══════════════════════════════════════════
#  MAIN MENU
# ══════════════════════════════════════════

func _build_main_menu() -> void:
	# Background gradient
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.05, 0.12, 1.0)
	main_menu.add_child(bg)

	# Decorative wave label (pure ambiance)
	var deco := Label.new()
	deco.text = "〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰"
	deco.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	deco.add_theme_font_size_override("font_size", 20)
	deco.add_theme_color_override("font_color", Color(0.2, 0.5, 0.8, 0.4))
	deco.set_anchors_preset(Control.PRESET_CENTER)
	deco.offset_top   = 80
	deco.offset_bottom = 110
	deco.offset_left   = -400
	deco.offset_right  = 400
	main_menu.add_child(deco)

	# Title
	var title := Label.new()
	title.text = "🦈  S H A R C"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0))
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top    = 100
	title.offset_bottom = 200
	main_menu.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Shark Sanctuary Idle"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.5, 0.7, 0.9))
	subtitle.set_anchors_preset(Control.PRESET_TOP_WIDE)
	subtitle.offset_top    = 190
	subtitle.offset_bottom = 230
	main_menu.add_child(subtitle)

	# Button column
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left   = -160
	vbox.offset_right  = 160
	vbox.offset_top    = -80
	vbox.offset_bottom = 180
	main_menu.add_child(vbox)

	var btn_new  := _make_menu_button("🐣  New Game")
	var btn_load := _make_menu_button("📂  Load Game")
	var btn_opts := _make_menu_button("⚙️  Options")
	var btn_exit := _make_menu_button("🚪  Exit")

	btn_new.pressed.connect(func(): _show_panel(new_game_panel))
	btn_load.pressed.connect(func(): _show_panel(load_game_panel))
	btn_opts.pressed.connect(func(): _show_panel(options_panel))
	btn_exit.pressed.connect(func(): get_tree().quit())

	vbox.add_child(btn_new)
	vbox.add_child(btn_load)
	vbox.add_child(btn_opts)
	vbox.add_child(btn_exit)


# ══════════════════════════════════════════
#  NEW GAME PANEL
# ══════════════════════════════════════════

func _build_new_game_panel() -> void:
	_add_panel_bg(new_game_panel, "🐣  New Game — Choose a Slot")

	var vbox := _add_panel_vbox(new_game_panel)

	for slot in range(MAX_SLOTS):
		var row := _make_slot_row_new(slot)
		vbox.add_child(row)

	var btn_back := _make_menu_button("← Back")
	btn_back.pressed.connect(func(): _show_panel(main_menu))
	vbox.add_child(btn_back)


func _make_slot_row_new(slot: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var info := Label.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.text = _slot_label(slot)
	info.add_theme_font_size_override("font_size", 14)
	row.add_child(info)

	var btn := Button.new()
	btn.text = "Start Here"
	btn.custom_minimum_size = Vector2(130, 0)
	btn.pressed.connect(func(): _start_new_game(slot))
	row.add_child(btn)

	return row


func _start_new_game(slot: int) -> void:
	# Wipe any existing save in that slot, then start fresh
	var path := SAVE_SLOT_PATH % slot
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	# Reset state manually (works even without the GameState patch)
	GameState.active_slot = slot if "active_slot" in GameState else 0
	GameState.currency              = 150
	GameState.passive_currency_rate = 10.0
	GameState.currency_multiplier   = 1.0
	GameState.shark_capacity        = 5
	GameState.housed_sharks         = []
	GameState.purchased_upgrades    = {}
	GameState.discovered_sharks     = {}
	GameState.egg_discovery_rate    = 1.0
	_launch_game()


# ══════════════════════════════════════════
#  LOAD GAME PANEL
# ══════════════════════════════════════════

func _build_load_game_panel() -> void:
	_add_panel_bg(load_game_panel, "📂  Load Game — Choose a Slot")

	var vbox := _add_panel_vbox(load_game_panel)

	for slot in range(MAX_SLOTS):
		var row := _make_slot_row_load(slot)
		vbox.add_child(row)

	var btn_back := _make_menu_button("← Back")
	btn_back.pressed.connect(func(): _show_panel(main_menu))
	vbox.add_child(btn_back)


func _make_slot_row_load(slot: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var info := Label.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.text = _slot_label(slot)
	info.add_theme_font_size_override("font_size", 14)
	row.add_child(info)

	var has_save := FileAccess.file_exists(SAVE_SLOT_PATH % slot)

	var btn_load := Button.new()
	btn_load.text     = "Load"
	btn_load.disabled = not has_save
	btn_load.custom_minimum_size = Vector2(90, 0)
	btn_load.pressed.connect(func(): _load_game(slot))
	row.add_child(btn_load)

	var btn_del := Button.new()
	btn_del.text     = "Delete"
	btn_del.disabled = not has_save
	btn_del.custom_minimum_size = Vector2(90, 0)
	btn_del.pressed.connect(func(): _delete_slot(slot))
	row.add_child(btn_del)

	return row


func _load_game(slot: int) -> void:
	GameState.active_slot = slot
	GameState.load_game_slot(slot)
	_launch_game()


func _delete_slot(slot: int) -> void:
	var path := SAVE_SLOT_PATH % slot
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	# Rebuild both panels so slot labels refresh everywhere
	for c in load_game_panel.get_children():
		c.queue_free()
	_build_load_game_panel()
	for c in new_game_panel.get_children():
		c.queue_free()
	_build_new_game_panel()


# ══════════════════════════════════════════
#  OPTIONS PANEL  (title-screen version)
# ══════════════════════════════════════════

func _build_options_panel() -> void:
	_add_panel_bg(options_panel, "⚙️  Options")

	var vbox := _add_panel_vbox(options_panel)

	# Music volume
	vbox.add_child(_make_section_label("🎵  Music Volume"))
	var music_slider := HSlider.new()
	music_slider.min_value = 0.0
	music_slider.max_value = 1.0
	music_slider.step      = 0.05
	music_slider.value     = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	music_slider.value     = _db_to_linear(AudioServer.get_bus_volume_db(
		_get_or_create_bus("Music")))
	music_slider.value_changed.connect(func(v): _set_bus_volume("Music", v))
	vbox.add_child(music_slider)

	# SFX volume
	vbox.add_child(_make_section_label("🔊  Sound Effects Volume"))
	var sfx_slider := HSlider.new()
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step      = 0.05
	sfx_slider.value     = _db_to_linear(AudioServer.get_bus_volume_db(
		_get_or_create_bus("SFX")))
	sfx_slider.value_changed.connect(func(v): _set_bus_volume("SFX", v))
	vbox.add_child(sfx_slider)

	# Fullscreen toggle
	vbox.add_child(_make_section_label("🖥️  Display"))
	var fs_check := CheckButton.new()
	fs_check.text    = "Fullscreen"
	fs_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fs_check.toggled.connect(func(on):
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED))
	vbox.add_child(fs_check)

	var btn_back := _make_menu_button("← Back")
	btn_back.pressed.connect(func(): _show_panel(main_menu))
	vbox.add_child(btn_back)


# ══════════════════════════════════════════
#  LAUNCH
# ══════════════════════════════════════════

func _launch_game() -> void:
	# ⚠ Set this to your actual Main scene path.
	# Run the game once after clicking Start Here — if the sanctuary doesn't
	# appear, check the Godot Output panel for "Found scene:" lines and
	# copy the correct path here.
	var main_scene_path := "res://Main.tscn"
	if not ResourceLoader.exists(main_scene_path):
		push_error("TitleScreen: Main scene not found at: " + main_scene_path)
		print("--- Scanning for .tscn files ---")
		_scan_tscn("res://")
		print("--- End scan. Copy the correct path above. ---")
		return
	get_tree().change_scene_to_file(main_scene_path)

func _scan_tscn(dir_path: String) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if not f.begins_with("."):
			if dir.current_is_dir():
				_scan_tscn(dir_path.path_join(f))
			elif f.ends_with(".tscn"):
				print("Found scene: ", dir_path.path_join(f))
		f = dir.get_next()


# ══════════════════════════════════════════
#  HELPERS
# ══════════════════════════════════════════

func _slot_label(slot: int) -> String:
	var path := SAVE_SLOT_PATH % slot
	if not FileAccess.file_exists(path):
		return "Slot %d  —  Empty" % (slot + 1)
	var file := FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed == null:
		return "Slot %d  —  Corrupt" % (slot + 1)
	var currency: int = parsed.get("currency", 0)
	var sharks:   int = parsed.get("housed_sharks_count", 0)
	return "Slot %d  —  💰 %d   🦈 %d sharks" % [slot + 1, currency, sharks]


func _make_menu_button(label: String) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(320, 48)
	return btn


func _make_section_label(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color(0.6, 0.85, 1.0))
	return lbl


func _add_panel_bg(panel: Control, title_text: String) -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.05, 0.12, 1.0)
	panel.add_child(bg)

	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0))
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top    = 40
	title.offset_bottom = 90
	panel.add_child(title)


func _add_panel_vbox(panel: Control) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top    = 100
	scroll.offset_left   = 80
	scroll.offset_right  = -80
	scroll.offset_bottom = -40
	panel.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 14)
	scroll.add_child(vbox)
	return vbox


func _get_or_create_bus(bus_name: String) -> int:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		AudioServer.add_bus()
		idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, bus_name)
	return idx


func _set_bus_volume(bus_name: String, linear: float) -> void:
	var idx := _get_or_create_bus(bus_name)
	AudioServer.set_bus_volume_db(idx, linear_to_db(linear))


func _db_to_linear(db: float) -> float:
	return db_to_linear(db)
