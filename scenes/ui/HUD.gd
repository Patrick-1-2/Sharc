extends CanvasLayer
# HUD.gd

@onready var currency_label:  Label  = $MarginContainerTop/VBox/CurrencyLabel
@onready var rate_label:      Label  = $MarginContainerTop/VBox/RateLabel
@onready var btn_hatchery:    Button = $MarginContainer/VBoxBtns/Buttons/BtnHatchery
@onready var btn_upgrades:    Button = $MarginContainer/VBoxBtns/Buttons/BtnUpgrades
@onready var btn_index:       Button = $MarginContainer/VBoxBtns/Buttons/BtnIndex
@onready var btn_options:     Button = $BtnOptions

@export var hatchery_scene: PackedScene
@export var index_scene:    PackedScene

func _ready() -> void:
	GameState.currency_changed.connect(_on_currency_changed)
	_refresh()

	btn_hatchery.pressed.connect(_open_hatchery)
	btn_upgrades.pressed.connect(_open_upgrades)
	btn_index.pressed.connect(_open_index)
	btn_options.pressed.connect(_open_options)

func _refresh() -> void:
	currency_label.text = "💰 %d" % GameState.currency
	rate_label.text     = "+%.1f / sec" % (GameState.passive_currency_rate * GameState.currency_multiplier)

func _on_currency_changed(_amount: int) -> void:
	_refresh()

func _open_hatchery() -> void:
	if hatchery_scene:
		get_tree().root.add_child(hatchery_scene.instantiate())
		hide()

func _open_upgrades() -> void:
	var existing := get_tree().root.get_node_or_null("UpgradeShop")
	if existing:
		existing.queue_free()
		show()
		return
	var shop: Node = load("res://scenes/ui/UpgradeShop.gd").new()
	shop.name = "UpgradeShop"
	get_tree().root.add_child(shop)
	hide()

func _open_index() -> void:
	if index_scene:
		var existing = get_tree().root.get_node_or_null("SharkIndex")
		if existing:
			existing.queue_free()
			show()
			return
		var index = index_scene.instantiate()
		index.name = "SharkIndex"
		get_tree().root.add_child(index)
		index.set_anchors_preset(Control.PRESET_FULL_RECT)
		index.offset_left = 0
		index.offset_top = 0
		index.offset_right = 0
		index.offset_bottom = 0
		hide()

func _open_options() -> void:
	var existing := get_node_or_null("InGameOptions")
	if existing:
		existing.queue_free()
		return
	var options: Node = load("res://scenes/ui/InGameOptions.gd").new()
	options.name = "InGameOptions"
	add_child(options)
