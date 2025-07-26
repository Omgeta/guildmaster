extends Control

signal select_adventurer(adv: AdventurerData)
signal select_item(item: ItemData, c: int)

const ADVENTURER_CARD_PCK = preload(
	"res://src/menus/gallery/ui/main_display/display_card/adventurer_card/adventurer_card.tscn"
)
const ITEM_CARD_PCK = preload(
	"res://src/menus/gallery/ui/main_display/display_card/item_card/item_card.tscn"
)

@onready var _list: GridContainer = $MarginContainer/VBoxContainer/ScrollContainer/GridContainer

enum Mode { Adventurer, Item }
var _mode: Mode = Mode.Adventurer


func _ready() -> void:
	_build_list()


func set_mode(m: Mode):
	if _mode != m:
		_mode = m
		_build_list()


func _build_list() -> void:
	for c in _list.get_children():
		c.queue_free()
	if _mode == Mode.Adventurer:
		for a in SaveManager.get_roster(true, true):
			var card := ADVENTURER_CARD_PCK.instantiate()
			_list.add_child(card)
			card.setup(a)
			card.pressed.connect(_on_adventurer_press.bind(a, card))
	else:
		var inv: Dictionary[String, int] = SaveManager.get_inventory()
		var items: Array = inv.keys().map(ItemDB.get_by_id)
		items.sort_custom(func(a, b): return a.rarity > b.rarity)
		for i in items:
			var count := inv[i.id]
			var card := ITEM_CARD_PCK.instantiate()
			_list.add_child(card)
			card.setup(i, count)
			card.pressed.connect(func(): select_item.emit(i, count))


func _on_adventurer_press(adv: AdventurerData, card: Control):
	SaveManager.touch_adventurer(adv.id)
	card.notify_seen()
	select_adventurer.emit(adv)


func _on_search_text_changed(new_text: String) -> void:
	for c in _list.get_children():
		var valid = c.get_search_id().to_lower().contains(new_text.to_lower()) or new_text == ""
		c.visible = valid
