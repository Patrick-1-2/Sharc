extends Control

const RARITY_NAMES = [
	"Least Concerned",
	"Near Threatened", 
	"Vulnerable",
	"Endangered",
	"Critically Endangered",
	"Special"
]

const RARITY_COLORS = [
	Color(0.4, 0.8, 0.4),
	Color(0.6, 0.8, 0.3),
	Color(1.0, 0.75, 0.2),
	Color(1.0, 0.4, 0.4),
	Color(0.8, 0.2, 0.8),
	Color(1.0, 0.85, 0.1),
]

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build()

func _build() -> void:
	for c in get_children():
		c.queue_free()

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.05, 0.1, 1.0)
	add_child(bg)

	var title := Label.new()
	title.text = "SHARK INDEX"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 12
	title.offset_bottom = 50
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)

	var prog := Label.new()
	prog.text = "%d / %d Discovered" % [GameState.discovered_sharks.size(), GameData.SHARK_CATALOG.size()]
	prog.add_theme_font_size_override("font_size", 14)
	prog.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	prog.set_anchors_preset(Control.PRESET_TOP_WIDE)
	prog.offset_top = 50
	prog.offset_bottom = 76
	prog.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(prog)

	var close := Button.new()
	close.text = "X"
	close.set_position(Vector2(get_viewport_rect().size.x - 52, 10))
	close.set_size(Vector2(40, 40))
	close.pressed.connect(queue_free)
	add_child(close)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 80
	scroll.offset_left = 16
	scroll.offset_right = -16
	scroll.offset_bottom = -16
	add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 20)
	scroll.add_child(vbox)

	var by_rarity: Array = []
	for i in range(6):
		by_rarity.append([])
	for shark in GameData.SHARK_CATALOG:
		by_rarity[shark.rarity].append(shark)

	for rarity in range(6):
		var tier: Array = by_rarity[rarity]
		if tier.is_empty():
			continue

		var found_count := 0
		for shark in tier:
			if GameState.discovered_sharks.has(shark.id):
				found_count += 1

		var header := Label.new()
		header.text = "— %s  (%d / %d) —" % [RARITY_NAMES[rarity], found_count, tier.size()]
		header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		header.add_theme_font_size_override("font_size", 16)
		header.add_theme_color_override("font_color", RARITY_COLORS[rarity])
		vbox.add_child(header)

		var grid := GridContainer.new()
		grid.columns = 4
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 10)
		vbox.add_child(grid)

		for shark in tier:
			grid.add_child(_make_card(shark, rarity))

func _make_card(shark: Dictionary, rarity: int) -> PanelContainer:
	var is_found: bool = GameState.discovered_sharks.has(shark.id)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(160, 120)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	panel.add_child(vbox)

	var bar := ColorRect.new()
	bar.custom_minimum_size = Vector2(0, 5)
	bar.color = RARITY_COLORS[rarity] if is_found else Color(0.25, 0.25, 0.25)
	vbox.add_child(bar)

	var icon := Label.new()
	icon.custom_minimum_size = Vector2(0, 55)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if is_found:
		icon.text = "🦈"
		icon.add_theme_font_size_override("font_size", 30)
	else:
		icon.text = "?"
		icon.add_theme_font_size_override("font_size", 36)
		icon.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35))
	vbox.add_child(icon)

	var name_lbl := Label.new()
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	name_lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(name_lbl)

	if is_found:
		name_lbl.text = shark.name
		var btn := Button.new()
		btn.text = "Info"
		btn.add_theme_font_size_override("font_size", 10)
		btn.pressed.connect(_show_popup.bind(shark, rarity))
		vbox.add_child(btn)
	else:
		name_lbl.text = "???"
		name_lbl.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35))

	return panel

func _show_popup(shark: Dictionary, rarity: int) -> void:
	var old = get_node_or_null("Popup")
	if old:
		old.queue_free()

	var popup := PanelContainer.new()
	popup.name = "Popup"
	popup.set_position(Vector2(get_viewport_rect().size.x * 0.2, get_viewport_rect().size.y * 0.25))
	popup.set_size(Vector2(get_viewport_rect().size.x * 0.6, 200))
	add_child(popup)

	var vbox := VBoxContainer.new()
	popup.add_child(vbox)

	var name_lbl := Label.new()
	name_lbl.text = shark.name
	name_lbl.add_theme_font_size_override("font_size", 18)
	name_lbl.add_theme_color_override("font_color", RARITY_COLORS[rarity])
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_lbl)

	var rarity_lbl := Label.new()
	rarity_lbl.text = RARITY_NAMES[rarity]
	rarity_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(rarity_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = shark.description
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc_lbl)

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(popup.queue_free)
	vbox.add_child(close_btn)
