extends Control

var current_rarity: int = 0

const RARITY_NAMES = [
	"Least Concerned",
	"Near Threatened",
	"Vulnerable",
	"Endangered",
	"Critically Endangered",
	"Special"
]

@onready var egg_label: Label = $Panel/VBoxContainer/EggDisplay/VBoxContainer/EggLabel
@onready var rarity_label: Label = $Panel/VBoxContainer/EggDisplay/VBoxContainer/RarityLabel
@onready var count_label: Label = $Panel/VBoxContainer/EggDisplay/VBoxContainer/CountLabel
@onready var btn_left: Button = $Panel/VBoxContainer/EggDisplay/BtnLeft
@onready var btn_right: Button = $Panel/VBoxContainer/EggDisplay/BtnRight
@onready var btn_hatch: Button = $Panel/VBoxContainer/BtnHatch
@onready var btn_close: Button = $Panel/VBoxContainer/HBoxContainer/BtnClose

func _ready() -> void:
	btn_close.pressed.connect(_on_close)
	btn_left.pressed.connect(_on_left)
	btn_right.pressed.connect(_on_right)
	btn_hatch.pressed.connect(_on_hatch)
	_refresh()

func _on_left() -> void:
	current_rarity = (current_rarity - 1 + 6) % 6
	_refresh()

func _on_right() -> void:
	current_rarity = (current_rarity + 1) % 6
	_refresh()

func _on_hatch() -> void:
	for i in GameState.inventory.size():
		var item = GameState.inventory[i]
		if item.type == "egg" and item.rarity == current_rarity:
			GameState.inventory.remove_at(i)
			var result = GameState.hatch_egg(item)
			if not result.is_empty():
				print("Hatched: ", result.name)
			_refresh()
			return
	print("No eggs of this type!")

func _refresh() -> void:
	var count = 0
	for item in GameState.inventory:
		if item.type == "egg" and item.rarity == current_rarity:
			count += 1
	rarity_label.text = RARITY_NAMES[current_rarity]
	count_label.text = "x%d" % count
	egg_label.text = "🥚"
	btn_hatch.disabled = count == 0

func _on_close() -> void:
	get_tree().root.get_node("Main/HUD").show()
	queue_free()
