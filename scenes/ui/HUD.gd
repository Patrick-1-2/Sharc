extends CanvasLayer
# HUD.gd
# Attach to a CanvasLayer node that holds your HUD Control nodes.
# Shows currency, passive rate, and navigation buttons.

@onready var currency_label:  Label  = $MarginContainerTop/VBox/CurrencyLabel
@onready var rate_label:      Label  = $MarginContainerTop/VBox/RateLabel
@onready var btn_hatchery:    Button = $MarginContainer/VBoxBtns/Buttons/BtnHatchery
@onready var btn_upgrades:    Button = $MarginContainer/VBoxBtns/Buttons/BtnUpgrades
@onready var btn_index:       Button = $MarginContainer/VBoxBtns/Buttons/BtnIndex

# Scenes to open (set in Inspector or via preload)
@export var hatchery_scene: PackedScene
@export var upgrade_scene:  PackedScene
@export var index_scene:    PackedScene

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
	if hatchery_scene:
		get_tree().root.add_child(hatchery_scene.instantiate())
		hide()

func _open_upgrades() -> void:
	if upgrade_scene:
		get_tree().root.add_child(upgrade_scene.instantiate())

func _open_index() -> void:
	if index_scene:
		get_tree().root.add_child(index_scene.instantiate())
