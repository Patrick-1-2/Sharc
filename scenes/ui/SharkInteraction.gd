extends Control
# SharkInteraction.gd
# Popup that appears when the player clicks a shark in the sanctuary.
# Wire Sanctuary.shark_clicked → show_for_shark().

@onready var name_label: Label = $Panel/VBox/NameLabel
@onready var rarity_label: Label = $Panel/VBox/RarityLabel
@onready var happiness_bar: ProgressBar = $Panel/VBox/HappinessBar
@onready var food_list: VBoxContainer = $Panel/VBox/FoodList
@onready var btn_pet: Button = $Panel/VBox/BtnPet
@onready var btn_release: Button = $Panel/VBox/BtnRelease
@onready var btn_close: Button = $Panel/BtnClose
@onready var feedback_label: Label = $Panel/VBox/FeedbackLabel

var _current_instance_id: String = ""

func _ready() -> void:
	btn_pet.pressed.connect(_on_pet)
	btn_release.pressed.connect(_on_release)
	btn_close.pressed.connect(queue_free)
	feedback_label.text = ""

func show_for_shark(instance_id: String) -> void:
	_current_instance_id = instance_id
	var shark: Dictionary = GameState._find_shark(instance_id)
	if shark.is_empty():
		queue_free()
		return

	name_label.text     = shark.name
	rarity_label.text   = _rarity_name(shark.rarity)
	happiness_bar.value = shark.get("happiness", 100)

	_populate_food_buttons()
	show()

func _populate_food_buttons() -> void:
	for child in food_list.get_children():
		child.queue_free()
	for i in GameData.FOOD_CATALOG.size():
		var food: Dictionary = GameData.FOOD_CATALOG[i]
		var btn: Button = Button.new()
		btn.text     = "%s (%d 💰)" % [food.name, food.cost]
		btn.disabled = GameState.currency < food.cost
		btn.pressed.connect(_on_feed.bind(i))
		food_list.add_child(btn)

func _on_pet() -> void:
	var bonus: int = GameState.pet_shark(_current_instance_id)
	feedback_label.text = "+%d 💰 from petting!" % bonus
	_refresh_happiness()

func _on_feed(food_id: int) -> void:
	var success: bool = GameState.feed_shark(_current_instance_id, food_id)
	if success:
		feedback_label.text = "Fed successfully!"
	else:
		feedback_label.text = "Not enough currency."
	_refresh_happiness()
	_populate_food_buttons()

func _on_release() -> void:
	GameState.release_shark(_current_instance_id)
	queue_free()

func _refresh_happiness() -> void:
	var shark: Dictionary = GameState._find_shark(_current_instance_id)
	if not shark.is_empty():
		happiness_bar.value = shark.get("happiness", 100)

func _rarity_name(rarity: int) -> String:
	match rarity:
		GameData.Rarity.LEAST_CONCERNED:       return "Least Concerned"
		GameData.Rarity.NEAR_THREATENED:       return "Near Threatened"
		GameData.Rarity.VULNERABLE:            return "Vulnerable"
		GameData.Rarity.ENDANGERED:            return "Endangered"
		GameData.Rarity.CRITICALLY_ENDANGERED: return "Critically Endangered"
		GameData.Rarity.SPECIAL:               return "Special ⭐"
	return "Unknown"
