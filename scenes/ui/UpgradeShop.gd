extends Control
# UpgradeShop.gd

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	# Force size to viewport in case anchors don't resolve (added to root Node)
	size = get_viewport_rect().size
	GameState.upgrade_purchased.connect(_on_upgrade_purchased)
	GameState.currency_changed.connect(_on_currency_changed)
	_build()

# ─── Build ────────────────────────────────────────────────────────────────────

func _build() -> void:
	for c in get_children():
		c.queue_free()

	# Background
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.05, 0.1, 1.0)
	add_child(bg)

	# Title
	var title := Label.new()
	title.text = "UPGRADE SHOP"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 12
	title.offset_bottom = 50
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)

	# Subtitle
	var purchased_count: int = 0
	for upgrade in GameData.UPGRADE_CATALOG:
		purchased_count += GameState.get_upgrade_level(upgrade.id)
	var total_levels: int = 0
	for upgrade in GameData.UPGRADE_CATALOG:
		total_levels += upgrade.max_level

	var sub := Label.new()
	sub.text = "%d / %d Levels Purchased" % [purchased_count, total_levels]
	sub.add_theme_font_size_override("font_size", 14)
	sub.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	sub.set_anchors_preset(Control.PRESET_TOP_WIDE)
	sub.offset_top = 50
	sub.offset_bottom = 76
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(sub)

	# Close button
	var close := Button.new()
	close.text = "X"
	close.set_position(Vector2(get_viewport_rect().size.x - 52, 10))
	close.set_size(Vector2(40, 40))
	close.pressed.connect(_on_close)
	add_child(close)

	# Scroll area
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 80
	scroll.offset_left = 16
	scroll.offset_right = -16
	scroll.offset_bottom = -16
	add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 12)
	scroll.add_child(vbox)

	for i in GameData.UPGRADE_CATALOG.size():
		vbox.add_child(_make_row(i))
		vbox.add_child(HSeparator.new())

# ─── Row card ─────────────────────────────────────────────────────────────────

func _make_row(upgrade_index: int) -> HBoxContainer:
	var upgrade:   Dictionary = GameData.UPGRADE_CATALOG[upgrade_index]
	var level:     int  = GameState.get_upgrade_level(upgrade_index)
	var maxed:     bool = level >= upgrade.max_level
	var next_cost: int  = GameData.upgrade_cost(upgrade, level)
	var affordable: bool = GameState.currency >= next_cost

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_lbl := Label.new()
	name_lbl.text = upgrade.name
	name_lbl.add_theme_font_size_override("font_size", 15)

	var effect_lbl := Label.new()
	effect_lbl.text = _effect_description(upgrade)
	effect_lbl.modulate = Color(0.7, 0.9, 1.0)
	effect_lbl.add_theme_font_size_override("font_size", 11)

	var level_lbl := Label.new()
	level_lbl.text = "Level %d / %d" % [level, upgrade.max_level]
	level_lbl.modulate = Color(0.2, 0.8, 0.2) if maxed else Color(0.6, 0.6, 0.6)
	level_lbl.add_theme_font_size_override("font_size", 11)

	var cost_lbl := Label.new()
	if maxed:
		cost_lbl.text     = "Maxed ✓"
		cost_lbl.modulate = Color(0.2, 0.8, 0.2)
	else:
		cost_lbl.text     = "💰 %d" % next_cost
		cost_lbl.modulate = Color(1.0, 1.0, 1.0) if affordable else Color(0.8, 0.3, 0.3)

	info.add_child(name_lbl)
	info.add_child(effect_lbl)
	info.add_child(level_lbl)
	info.add_child(cost_lbl)
	row.add_child(info)

	var btn := Button.new()
	if maxed:
		btn.text     = "Maxed"
		btn.disabled = true
	else:
		btn.text     = "Buy"
		btn.disabled = not affordable
		btn.pressed.connect(_on_buy.bind(upgrade_index))
	row.add_child(btn)

	return row

# ─── Helpers ──────────────────────────────────────────────────────────────────

func _effect_description(upgrade: Dictionary) -> String:
	match upgrade.effect:
		"shark_capacity":     return "+%d shark slots per level" % upgrade.value
		"passive_currency":   return "+%d currency / sec per level" % upgrade.value
		"currency_mult":      return "x%.2f currency multiplier per level" % upgrade.value
		"egg_discovery_rate": return "x%.1f egg discovery rate per level" % upgrade.value
	return ""

# ─── Signals ──────────────────────────────────────────────────────────────────

func _on_buy(upgrade_id: int) -> void:
	GameState.buy_upgrade(upgrade_id)

func _on_upgrade_purchased(_id: int) -> void:
	_build()

func _on_currency_changed(_amount: int) -> void:
	_build()

func _on_close() -> void:
	var hud := get_tree().root.get_node_or_null("Main/HUD")
	if hud:
		hud.show()
	queue_free()
