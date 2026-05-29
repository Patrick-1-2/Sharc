extends Node
# Main.gd

func _ready() -> void:
	GameState.game_won.connect(_on_game_won)
	GameState.game_lost.connect(_on_game_lost)

	# Make the sanctuary visible
	var sanctuary := get_node_or_null("World/Sanctuary")
	if sanctuary:
		sanctuary.visible = true

	# Start passive income ticking — this was the cause of currency not increasing
	GameState.activate_passive_income()

func _on_game_won() -> void:
	print("Victory!")

func _on_game_lost() -> void:
	print("Loss condition triggered.")
