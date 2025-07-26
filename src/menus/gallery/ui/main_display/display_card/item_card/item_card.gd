extends "res://src/menus/gallery/ui/main_display/display_card/display_card.gd"

const COLOR_UTIL := preload("res://src/utils/ColorUtil.gd")

@onready var _tex: TextureRect = $TextureRect
@onready var _label: Label = $MarginContainer/Label

var _item: ItemData


func setup(item: ItemData, count: int = 1) -> void:
	_item = item
	_tex.texture = item.icon
	_label.text = str(count)
	tooltip_text = ("%s %d⭐" % [item.name, item.rarity])
	self_modulate = COLOR_UTIL.new().get_rarity_color(item.rarity)


func get_search_id() -> String:
	if not _item:
		push_error("ItemCard: Item has no ItemData assigned")
	return _item.name
