extends Node

signal currency_changed(new_amount)
signal shark_hatched(shark_data)
signal upgrade_purchased(upgrade_id)
signal index_completed()
signal game_won()
signal game_lost()

var currency: int = 0:
	set(value):
		currency = value
		emit_signal("currency_changed", currency)

var passive_currency_rate: float = 5.0
var currency_multiplier: float = 1.0

var shark_capacity: int = 5
var housed_sharks: Array = []
var purchased_upgrades: Dictionary = {}
var egg_discovery_rate: float = 1.0

var discovered_sharks: Dictionary = {}

var _passive_timer: float = 0.0
const PASSIVE_TICK_INTERVAL: float = 1.0

var active_slot: int = 0         
var _passive_active: bool = false 

func _ready() -> void:
	currency = 150

func _process(delta: float) -> void:
	if not _passive_active:
		return
	_passive_timer += delta
	if _passive_timer >= PASSIVE_TICK_INTERVAL:
		_passive_timer = 0.0
		_tick_passive_income()

func _tick_passive_income() -> void:
	var income := int(passive_currency_rate * currency_multiplier)
	if income > 0:
		currency += income

func recalculate_passive_rate() -> void:
	var base: float = 0.0
	for shark in housed_sharks:
		base += _get_shark_base_income(shark.rarity)
	passive_currency_rate = base
	_recalculate_affinity_multiplier()

func _get_shark_base_income(rarity: int) -> float:
	match rarity:
		0: return 5.0
		1: return 12.0
		2: return 25.0
		3: return 50.0
		4: return 100.0
		5: return 300.0
	return 0.0

func _recalculate_affinity_multiplier() -> void:
	var groups := {}
	for shark in housed_sharks:
		var group: String = shark.get("affinity_group", "")
		if group != "":
			groups[group] = true
	var mult: float = 1.0
	for group in groups.keys():
		var buff: Dictionary = GameData.AFFINITY_BUFFS.get(group, {})
		mult += buff.get("currency_mult", 1.0) - 1.0
	currency_multiplier = mult

func hatch_egg(egg_item: Dictionary) -> Dictionary:
	var rarity: int = egg_item.get("rarity", 0)
	var result: Dictionary = GameData.pick_weighted_shark(rarity)
	if result.is_empty():
		push_warning("No sharks defined for rarity %d" % rarity)
		return {}
	result["instance_id"] = _generate_id()
	if not discovered_sharks.has(result.id):
		discovered_sharks[result.id] = true
	emit_signal("shark_hatched", result)
	_check_index_complete()
	return result

func _generate_id() -> String:
	return "%d_%d" % [Time.get_ticks_msec(), randi()]

func add_shark_to_sanctuary(shark: Dictionary) -> bool:
	if housed_sharks.size() >= shark_capacity:
		return false
	housed_sharks.append(shark)
	recalculate_passive_rate()
	return true

func release_shark(instance_id: String) -> void:
	housed_sharks = housed_sharks.filter(func(s): return s.instance_id != instance_id)
	recalculate_passive_rate()

func get_upgrade_level(upgrade_id: int) -> int:
	return purchased_upgrades.get(upgrade_id, 0)

func buy_upgrade(upgrade_id: int) -> bool:
	var upgrade: Dictionary = GameData.UPGRADE_CATALOG[upgrade_id]
	var current_level: int = get_upgrade_level(upgrade_id)
	if current_level >= upgrade.max_level:
		return false
	var cost: int = GameData.upgrade_cost(upgrade, current_level)
	if currency < cost:
		return false
	currency -= cost
	purchased_upgrades[upgrade_id] = current_level + 1
	_apply_upgrade(upgrade)
	emit_signal("upgrade_purchased", upgrade_id)
	_check_victory()
	return true

func reset() -> void:
	currency              = 150
	passive_currency_rate = 10.0
	currency_multiplier   = 1.0
	shark_capacity        = 5
	housed_sharks         = []
	purchased_upgrades    = {}
	discovered_sharks     = {}
	egg_discovery_rate    = 1.0
	_passive_timer        = 0.0
	_passive_active       = false   # will be activated by Main.gd after scene loads
 
func activate_passive_income() -> void:
	_passive_active = true
	
func _apply_upgrade(upgrade: Dictionary) -> void:
	match upgrade.effect:
		"shark_capacity":     shark_capacity += upgrade.value
		"passive_currency":   passive_currency_rate += upgrade.value
		"currency_mult":      currency_multiplier *= upgrade.value
		"egg_discovery_rate": egg_discovery_rate *= upgrade.value

func _check_index_complete() -> void:
	if discovered_sharks.size() >= GameData.SHARK_CATALOG.size():
		emit_signal("index_completed")
		_check_victory()

func _check_victory() -> void:
	var all_maxed: bool = true
	for upgrade in GameData.UPGRADE_CATALOG:
		if get_upgrade_level(upgrade.id) < upgrade.max_level:
			all_maxed = false
			break
	var index_full: bool = discovered_sharks.size() >= GameData.SHARK_CATALOG.size()
	if all_maxed and index_full:
		emit_signal("game_won")

func trigger_loss() -> void:
	emit_signal("game_lost")
const SAVE_SLOT_PATH := "user://sharc_save_slot_%d.json"
 
func save() -> void:
	var data := {
		"currency":             currency,
		"passive_rate":         passive_currency_rate,
		"currency_mult":        currency_multiplier,
		"shark_capacity":       shark_capacity,
		"housed_sharks":        housed_sharks,
		"housed_sharks_count":  housed_sharks.size(),   # for slot preview
		"purchased_upgrades":   purchased_upgrades,
		"discovered_sharks":    discovered_sharks,
		"egg_discovery_rate":   egg_discovery_rate,
	}
	var path := SAVE_SLOT_PATH % active_slot
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	
func load_game_slot(slot: int) -> void:
	active_slot = slot
	var path := SAVE_SLOT_PATH % slot
	if not FileAccess.file_exists(path):
		return
	var file   := FileAccess.open(path, FileAccess.READ)
	var parsed  = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed == null:
		return
	currency              = parsed.get("currency",           currency)
	passive_currency_rate = parsed.get("passive_rate",       passive_currency_rate)
	currency_multiplier   = parsed.get("currency_mult",      currency_multiplier)
	shark_capacity        = parsed.get("shark_capacity",     shark_capacity)
	housed_sharks         = parsed.get("housed_sharks",      housed_sharks)
	purchased_upgrades    = parsed.get("purchased_upgrades", purchased_upgrades)
	discovered_sharks     = parsed.get("discovered_sharks",  discovered_sharks)
	egg_discovery_rate    = parsed.get("egg_discovery_rate", egg_discovery_rate)
	_passive_active       = true  # loaded game starts earning immediately
 
func load_game() -> void:
	load_game_slot(active_slot)
