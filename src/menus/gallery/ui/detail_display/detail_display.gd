extends Control

signal equip_requested(item: ItemData)

@onready var _adv_display := $MarginContainer/AdventurerDisplay
@onready var _item_display := $MarginContainer/ItemDisplay


func show_adventurer(adv: AdventurerData) -> void:
	_adv_display.populate(adv)
	_item_display.visible = false
	_adv_display.visible = true


func show_item(item: ItemData, count: int) -> void:
	_item_display.populate(item, count)
	_adv_display.visible = false
	_item_display.visible = true


func clear() -> void:
	_adv_display.visible = false
	_item_display.visible = false


func _on_item_display_equip_requested(item: ItemData) -> void:
	equip_requested.emit(item)
