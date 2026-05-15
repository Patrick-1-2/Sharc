extends Node

func _ready() -> void:
	GameState.load_game()
	GameState.game_won.connect(_on_game_won)
	GameState.game_lost.connect(_on_game_lost)

func _on_game_won() -> void:
	print("Victory!")

func _on_game_lost() -> void:
	print("Loss condition triggered.")
