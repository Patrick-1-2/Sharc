extends Control
# SharkIndex.gd
# Attach to a Control node (popup / full-screen panel).
# Shows the full catalog of 50 sharks; undiscovered ones appear as "???"

@onready var grid:      GridContainer = $Panel/ScrollContainer/Grid
@onready var btn_close: Button        = $Panel/BtnClose
@onready var detail_panel: PanelContainer = $Panel/DetailPanel
@onready var detail_name:  Label          = $Panel/DetailPanel/VBox/Name
@onready var detail_desc:  Label          = $Panel/DetailPanel/VBox/Description
@onready var detail_rarity:Label          = $Panel/DetailPanel/VBox/Rarity

func _ready() -> void:
	btn_close.pressed.connect(queue_free)
	detail_panel.visible = false
	_populate()

func _populate() -> void:
	for child in grid.get_children():
		child.queue_free()

	for shark in GameData.SHARK_CATALOG:
		var discovered: bool = GameState.discovered_sharks.has(shark.id)
		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(120, 80)

		if discovered:
			btn.text    = shark.name
			btn.tooltip_text = shark.description
			btn.pressed.connect(_show_detail.bind(shark))
		else:
			btn.text    = "???"
			btn.modulate = Color(0.3, 0.3, 0.3)  # greyed out
		grid.add_child(btn)

	# Show discovery progress
	var progress_lbl: Label = Label.new()
	progress_lbl.text = "%d / %d Discovered" % [GameState.discovered_sharks.size(), GameData.SHARK_CATALOG.size()]
	grid.add_child(progress_lbl)

func _show_detail(shark: Dictionary) -> void:
	detail_name.text   = shark.name
	detail_desc.text   = shark.description
	detail_rarity.text = "Rarity: " + _rarity_name(shark.rarity)
	detail_panel.visible = true

func _rarity_name(rarity: int) -> String:
	match rarity:
		GameData.Rarity.LEAST_CONCERNED:       return "Least Concerned"
		GameData.Rarity.NEAR_THREATENED:       return "Near Threatened"
		GameData.Rarity.VULNERABLE:            return "Vulnerable"
		GameData.Rarity.ENDANGERED:            return "Endangered"
		GameData.Rarity.CRITICALLY_ENDANGERED: return "Critically Endangered"
		GameData.Rarity.SPECIAL:               return "Special"
	return "Unknown"
