extends CanvasLayer
# HUD.gd

@onready var currency_label: Label  = $MarginContainerTop/VBox/CurrencyLabel
@onready var rate_label:     Label  = $MarginContainerTop/VBox/RateLabel
@onready var btn_hatchery:   Button = $MarginContainer/VBoxBtns/Buttons/BtnHatchery
@onready var btn_upgrades:   Button = $MarginContainer/VBoxBtns/Buttons/BtnUpgrades
@onready var btn_index:      Button = $MarginContainer/VBoxBtns/Buttons/BtnIndex

func _ready() -> void:
	GameState.currency_changed.connect(_on_currency_changed)
	_refresh()

	btn_hatchery.pressed.connect(_open_hatchery)
	btn_upgrades.pressed.connect(_open_upgrades)
	btn_index.pressed.connect(_open_index)

func _refresh() -> void:
	currency_label.text = "💰 %d" % GameState.currency
	rate_label.text     = "+%.1f / sec" % (GameState.passive_currency_rate * GameState.currency_multiplier)

func _on_currency_changed(_amount: int) -> void:
	_refresh()

func _open_hatchery() -> void:
	var existing = get_node_or_null("Hatchery")
	if existing:
		existing.queue_free()
		return
	var hatchery = load("res://scenes/ui/Hatchery.gd").new()
	hatchery.name = "Hatchery"
	add_child(hatchery)
	hatchery.set_anchors_preset(Control.PRESET_FULL_RECT)
	hatchery.offset_left   = 0
	hatchery.offset_top    = 0
	hatchery.offset_right  = 0
	hatchery.offset_bottom = 0

func _open_upgrades() -> void:
	var existing = get_node_or_null("UpgradeShop")
	if existing:
		existing.queue_free()
		return
	var shop = load("res://scenes/ui/UpgradeShop.gd").new()
	shop.name = "UpgradeShop"
	add_child(shop)
	shop.set_anchors_preset(Control.PRESET_FULL_RECT)
	shop.offset_left   = 0
	shop.offset_top    = 0
	shop.offset_right  = 0
	shop.offset_bottom = 0

func _open_index() -> void:
	var existing = get_node_or_null("SharkIndex")
	if existing:
		existing.queue_free()
		return
	var index = load("res://scenes/ui/SharkIndex.gd").new()
	index.name = "SharkIndex"
	add_child(index)
	index.set_anchors_preset(Control.PRESET_FULL_RECT)
	index.offset_left   = 0
	index.offset_top    = 0
	index.offset_right  = 0
	index.offset_bottom = 0
