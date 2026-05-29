extends Node2D

@onready var shark_container: Node2D = $SharkContainer

const SharkScene := preload("res://scenes/world/SharkSprite.tscn")

# ── Change this path to your image, e.g. "res://assets/ocean_bg.png" ──────────
const BG_IMAGE_PATH := "res://assets/sanctuary_bg.png"

func _ready() -> void:
	_setup_background()
	# Move SharkContainer to screen center so its local (0,0) is the tank center
	var vp_size := get_viewport_rect().size
	shark_container.position = vp_size / 2.0
	GameState.shark_hatched.connect(_on_shark_hatched)
	_populate_existing_sharks()

func _setup_background() -> void:
	var old_bg := get_node_or_null("Background")
	if old_bg:
		old_bg.queue_free()

	var vp_size := get_viewport_rect().size

	if ResourceLoader.exists(BG_IMAGE_PATH):
		var bg := Sprite2D.new()
		bg.name = "Background"
		bg.texture = load(BG_IMAGE_PATH)
		bg.position = vp_size / 2.0
		var tex_size: Vector2 = bg.texture.get_size()
		if tex_size.x > 0 and tex_size.y > 0:
			bg.scale = Vector2(vp_size.x / tex_size.x, vp_size.y / tex_size.y)
		add_child(bg)
		move_child(bg, 0)
	else:
		var bg := ColorRect.new()
		bg.name = "Background"
		bg.color = Color(0.33, 0.80, 0.93, 1.0)
		bg.position = Vector2.ZERO
		bg.size = vp_size
		add_child(bg)
		move_child(bg, 0)

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
	# Spawn at center of tank — SharkContainer is already offset to screen center
	sprite.position = Vector2.ZERO
	print("Sprite position: ", sprite.position)
