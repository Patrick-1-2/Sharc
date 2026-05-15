extends Node2D

signal clicked(instance_id)

var shark_data: Dictionary = {}
var swim_speed: float = 60.0
var swim_direction: Vector2 = Vector2.RIGHT
var _direction_timer: float = 0.0
const DIRECTION_CHANGE_INTERVAL: float = 3.0
const TANK_RECT := Rect2(50, 50, 1050, 550)

func setup(data: Dictionary) -> void:
	shark_data = data
	swim_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	var poly = Polygon2D.new()
	poly.polygon = PackedVector2Array([
	Vector2(-50, -30),
	Vector2(50, -30),
	Vector2(50, 30),
	Vector2(-50, 30)
	])
	poly.color = Color(0.3, 0.3, 0.3)
	add_child(poly)

func _process(delta: float) -> void:
	_direction_timer += delta
	if _direction_timer >= DIRECTION_CHANGE_INTERVAL:
		_direction_timer = 0.0
		swim_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

	position += swim_direction * swim_speed * delta

	if position.x < TANK_RECT.position.x or position.x > TANK_RECT.end.x:
		swim_direction.x = -swim_direction.x
		position.x = clamp(position.x, TANK_RECT.position.x, TANK_RECT.end.x)

	if position.y < TANK_RECT.position.y or position.y > TANK_RECT.end.y:
		swim_direction.y = -swim_direction.y
		position.y = clamp(position.y, TANK_RECT.position.y, TANK_RECT.end.y)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var distance = global_position.distance_to(get_viewport().get_mouse_position())
		if distance < 70:
			print("Shark clicked: ", shark_data.get("name", "unknown"))
			emit_signal("clicked", shark_data.get("instance_id", ""))
			get_viewport().set_input_as_handled()
