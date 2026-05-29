extends Node2D
# SharkSprite.gd
# Place at: res://scenes/world/SharkSprite.gd
# SharkSprite.tscn must have a Sprite2D child node named "Sprite2D"

@onready var sprite: Sprite2D = $Sprite2D

const ASSET_PATH := "res://assets/"
const SPRITE_SCALE := Vector2(0.12, 0.12)

# Bouncing movement
var velocity: Vector2 = Vector2.ZERO
const SPEED_MIN := 60.0
const SPEED_MAX := 130.0

# Sanctuary bounds — centered at (0,0) to match SharkContainer local space
const BOUND_LEFT   := -500.0
const BOUND_RIGHT  :=  500.0
const BOUND_TOP    := -200.0
const BOUND_BOTTOM :=  180.0

# Maps every GameData SHARK_CATALOG "name" → PNG filename (without .png)
const NAME_TO_ASSET: Dictionary = {
	# LEAST CONCERNED
	"Leopard Shark":        "ZEBRASHARK",
	"Nurse Shark":          "NURSESHARK",
	"Epaulette Shark":      "ZEBRASHARK",
	"Cat Shark":            "COOKIECUTTER",
	"Smoothhound":          "BLACKTIP",
	"Whiskery Shark":       "SILVERTIP",
	"Horn Shark":           "SANDBARSHARK",
	# NEAR THREATENED
	"Zebra Shark":          "ZEBRASHARK",
	"Angel Shark":          "WOBBEGONG",
	"School Shark":         "BLUESHARK",
	"Silvertip Shark":      "SILVERTIP",
	"Salmon Shark":         "MAKOSHARK",
	"Night Shark":          "DUSKYSHARK",
	"Milk Shark":           "LEMONSHARK",
	# VULNERABLE
	"Hammerhead Shark":     "HAMMERHEAD",
	"Bull Shark":           "BULLSHARK",
	"Lemon Shark":          "LEMONSHARK",
	"Sandbar Shark":        "SANDBARSHARK",
	"Spinner Shark":        "BLACKTIP",
	"Silky Shark":          "SILKYSHARK",
	"Finetooth Shark":      "CARRIBEANREEFSHARK",
	"Hardnose Shark":       "GALAPAGOS",
	"Kitefin Shark":        "GOBLINSHARK",
	"Cookiecutter Shark":   "COOKIECUTTER",
	# ENDANGERED
	"Dusky Shark":          "DUSKYSHARK",
	"Goblin Shark":         "GOBLINSHARK",
	"Frilled Shark":        "FRILLEDSHARK",
	"Gulper Shark":         "CRETOXYRHINA",
	"Sombre Catshark":      "STETHACANTHUS",
	"Velvet Dogfish":       "XENACANTHUS",
	"Mosaic Gulper Shark":  "CLADOSELACHE",
	# CRITICALLY ENDANGERED
	"Great White Shark":    "GREATWHITE",
	"Whale Shark":          "WHALESHARK",
	"Basking Shark":        "WHALESHARK",
	"Greenland Shark":      "GREENLANDSHARK",
	"Bahamas Sawshark":     "SAWSHARK",
	"Winghead Shark":       "HAMMERHEAD",
	"Slit-eye Shark":       "SILKYSHARK",
	# SPECIAL
	"Megalodon":            "MEGALODON",
	"Megamouth Shark":      "MEGAMOUTH",
	"Pacific Sleeper Shark":"GREENLANDSHARK",
	"Pinocchio Catshark":   "GOBLINSHARK",
	"Ornate Dogfish":       "XENACANTHUS",
	"Novaliches Shark":     "TIGERSHARK",
	"Tralalero Tralala":    "TRALELOTRALALA",
	"Plunket Shark":        "CLADOSELACHE",
	"Frog Shark":           "WOBBEGONG",
}

func setup(data: Dictionary) -> void:
	var shark_name: String = data.get("name", "")

	if shark_name == "":
		push_warning("SharkSprite: shark data has no 'name' key. Data: " + str(data))
		_show_debug_placeholder("no name")
		return

	var asset_key: String = NAME_TO_ASSET.get(shark_name, "")

	if asset_key == "":
		push_warning("SharkSprite: no asset mapping for shark '%s'" % shark_name)
		_show_debug_placeholder(shark_name)
		return

	var path := ASSET_PATH + asset_key + ".png"

	if not ResourceLoader.exists(path):
		push_warning("SharkSprite: PNG not found at '%s' for shark '%s'" % [path, shark_name])
		_show_debug_placeholder(asset_key)
		return

	sprite.texture = load(path)
	sprite.scale = SPRITE_SCALE

	# Random starting velocity
	var angle := randf() * TAU
	var speed := randf_range(SPEED_MIN, SPEED_MAX)
	velocity = Vector2(cos(angle), sin(angle)) * speed

	# Flip sprite to face movement direction
	_update_flip()

func _process(delta: float) -> void:
	if velocity == Vector2.ZERO:
		return

	position += velocity * delta

	# Bounce off left/right walls
	# Clamp position first, then force velocity away from the wall using abs().
	# This prevents the shark getting stuck if it overshoots by more than one frame.
	if position.x < BOUND_LEFT:
		position.x = BOUND_LEFT
		velocity.x = abs(velocity.x)   # force rightward, no matter what
		_update_flip()
	elif position.x > BOUND_RIGHT:
		position.x = BOUND_RIGHT
		velocity.x = -abs(velocity.x)  # force leftward, no matter what
		_update_flip()

	# Bounce off top/bottom walls
	if position.y < BOUND_TOP:
		position.y = BOUND_TOP
		velocity.y = abs(velocity.y)   # force downward
	elif position.y > BOUND_BOTTOM:
		position.y = BOUND_BOTTOM
		velocity.y = -abs(velocity.y)  # force upward

func _update_flip() -> void:
	# Flip so the shark always faces the direction it swims
	sprite.flip_h = velocity.x < 0

func _show_debug_placeholder(label_text: String) -> void:
	var rect := ColorRect.new()
	rect.size = Vector2(80, 60)
	rect.color = Color(0.1, 0.2, 0.45)
	rect.position = Vector2(-40, -30)
	add_child(rect)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 9)
	lbl.position = Vector2(-38, -8)
	add_child(lbl)
