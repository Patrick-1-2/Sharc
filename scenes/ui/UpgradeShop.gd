extends Control
# UpgradeShop.gd
# Attach to a Control node (popup / full-screen panel).
# Lists all sanctuary upgrades and lets the player purchase them.

@onready var upgrade_list: VBoxContainer = $Panel/ScrollContainer/UpgradeList
@onready var btn_close:    Button        = $Panel/BtnClose

func _ready() -> void:
	btn_close.pressed.connect(queue_free)
	GameState.upgrade_purchased.connect(_on_upgrade_purchased)
	_populate()

func _populate() -> void:
	for child in upgrade_list.get_children():
		child.queue_free()

	for i in GameData.UPGRADE_CATALOG.size():
		var upgrade: Dictionary = GameData.UPGRADE_CATALOG[i]
		var owned:   bool       = GameState.purchased_upgrades.has(i)
		var affordable: bool    = GameState.currency >= upgrade.cost

		var row: HBoxContainer = HBoxContainer.new()

		var lbl: Label = Label.new()
		lbl.text = "%s  —  %d 💰" % [upgrade.name, upgrade.cost]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)

		var btn: Button = Button.new()
		if owned:
			btn.text     = "Owned ✓"
			btn.disabled = true
		else:
			btn.text     = "Buy"
			btn.disabled = not affordable
			btn.pressed.connect(_on_buy.bind(i))
		row.add_child(btn)

		upgrade_list.add_child(row)

func _on_buy(upgrade_id: int) -> void:
	GameState.buy_upgrade(upgrade_id)

func _on_upgrade_purchased(_id: int) -> void:
	_populate()   # Refresh list after purchase
