extends Control

const RARITY_NAMES = [
	"Least Concerned",
	"Near Threatened",
	"Vulnerable",
	"Endangered",
	"Critically Endangered",
	"Special"
]

var current_rarity: int = 0

# Built nodes — kept as vars so _refresh() can reach them
var _egg_label:    Label
var _rarity_label: Label
var _cost_label:   Label
var _btn_hatch:    Button

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	GameState.currency_changed.connect(_on_currency_changed)
	_build()

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
	title.text = "HATCHERY"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 12
	title.offset_bottom = 50
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)

	# Close button (top-right X)
	var btn_close := Button.new()
	btn_close.text = "X"
	btn_close.set_position(Vector2(get_viewport_rect().size.x - 52, 10))
	btn_close.set_size(Vector2(40, 40))
	btn_close.pressed.connect(_on_close)
	add_child(btn_close)

	# Centre container
	var centre := VBoxContainer.new()
	centre.set_anchors_preset(Control.PRESET_CENTER)
	centre.add_theme_constant_override("separation", 16)
	centre.grow_horizontal = Control.GROW_DIRECTION_BOTH
	centre.grow_vertical   = Control.GROW_DIRECTION_BOTH
	add_child(centre)

	# Egg emoji
	_egg_label = Label.new()
	_egg_label.text = "🥚"
	_egg_label.add_theme_font_size_override("font_size", 72)
	_egg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	centre.add_child(_egg_label)

	# Rarity label
	_rarity_label = Label.new()
	_rarity_label.add_theme_font_size_override("font_size", 18)
	_rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	centre.add_child(_rarity_label)

	# Cost label
	_cost_label = Label.new()
	_cost_label.add_theme_font_size_override("font_size", 14)
	_cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	centre.add_child(_cost_label)

	# Left / Right arrow row
	var arrow_row := HBoxContainer.new()
	arrow_row.add_theme_constant_override("separation", 24)
	arrow_row.alignment = BoxContainer.ALIGNMENT_CENTER
	centre.add_child(arrow_row)

	var btn_left := Button.new()
	btn_left.text = "◀"
	btn_left.pressed.connect(_on_left)
	arrow_row.add_child(btn_left)

	var btn_right := Button.new()
	btn_right.text = "▶"
	btn_right.pressed.connect(_on_right)
	arrow_row.add_child(btn_right)

	# Hatch button
	_btn_hatch = Button.new()
	_btn_hatch.text = "Hatch Egg"
	_btn_hatch.add_theme_font_size_override("font_size", 16)
	_btn_hatch.pressed.connect(_on_hatch)
	centre.add_child(_btn_hatch)

	_refresh()

# ── Logic (unchanged from original) ──────────────────────────────────────────

func _on_left() -> void:
	current_rarity = (current_rarity - 1 + 6) % 6
	_refresh()

func _on_right() -> void:
	current_rarity = (current_rarity + 1) % 6
	_refresh()

func _on_hatch() -> void:
	var cost: int = GameData.EGG_COSTS[current_rarity]
	if GameState.currency < cost:
		return
	GameState.currency -= cost
	var result = GameState.hatch_egg({ "type": "egg", "rarity": current_rarity })
	if not result.is_empty():
		print("Hatched: ", result.name)
	_refresh()

func _refresh() -> void:
	var cost: int = GameData.EGG_COSTS[current_rarity]
	var can_afford: bool = GameState.currency >= cost
	_rarity_label.text    = RARITY_NAMES[current_rarity]
	_cost_label.text      = "💰 %d" % cost
	_cost_label.modulate  = Color(1, 1, 1) if can_afford else Color(0.8, 0.3, 0.3)
	_btn_hatch.disabled   = not can_afford

func _on_currency_changed(_amount: int) -> void:
	_refresh()

func _on_close() -> void:
	var hud = get_tree().get_root().find_child("HUD", true, false)
	if hud:
		hud.show()
	queue_free()
