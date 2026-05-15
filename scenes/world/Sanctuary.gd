extends Node2D

signal shark_clicked(instance_id)

@onready var shark_container: Node2D = $SharkContainer

const SharkScene := preload("res://scenes/world/SharkSprite.tscn")
const InteractionScene := preload("res://scenes/ui/SharkInteraction.tscn")

func _ready() -> void:
	GameState.shark_hatched.connect(_on_shark_hatched)
	_populate_existing_sharks()

func _populate_existing_sharks() -> void:
	for shark in GameState.housed_sharks:
		_spawn_shark_sprite(shark)

func _on_shark_hatched(shark: Dictionary) -> void:
	if GameState.add_shark_to_sanctuary(shark):
		_spawn_shark_sprite(shark)
	else:
		print("Sanctuary full! Choose to release or wait.")

func _spawn_shark_sprite(shark: Dictionary) -> void:
	print("Spawning sprite for: ", shark.name)
	var sprite = SharkScene.instantiate()
	shark_container.add_child(sprite)
	sprite.setup(shark)
	sprite.position = Vector2(576, 324)  # dead center of screen
	print("Sprite position: ", sprite.position)
	
func _on_shark_sprite_clicked(instance_id: String) -> void:
	emit_signal("shark_clicked", instance_id)
	var popup = InteractionScene.instantiate()
	get_tree().root.add_child(popup)
	popup.show_for_shark(instance_id)
