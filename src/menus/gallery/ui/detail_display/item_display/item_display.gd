extends Control

@onready var _name: Label = $VBoxContainer/Name
@onready var _description: Label = $VBoxContainer/Description
@onready var _bg: Panel = $VBoxContainer/MarginContainer/SpriteContainer
@onready var _tex: TextureRect = $VBoxContainer/MarginContainer/SpriteContainer/Image
@onready var _slot: Label = $VBoxContainer/MarginContainer/SpriteContainer/MarginContainer/Slot
@onready var _stack: Label = $VBoxContainer/MarginContainer/SpriteContainer/MarginContainer/Stack
@onready var _heal: Label = $VBoxContainer/VSplitContainer/Stats/HEAL/Value
@onready var _hp: Label = $VBoxContainer/VSplitContainer/Stats/HP/Value
@onready var _atk: Label = $VBoxContainer/VSplitContainer/Stats/ATK/Value
@onready var _mag: Label = $VBoxContainer/VSplitContainer/Stats/MAG/Value
@onready var _dex: Label = $VBoxContainer/VSplitContainer/Stats/DEX/Value

const ColorUtil = preload("res://src/utils/ColorUtil.gd")


func populate(item: ItemData, count: int):
	_name.text = item.name
	_description.text = item.description
	_bg.self_modulate = ColorUtil.new().get_rarity_color(item.rarity)
	_tex.texture = item.icon
	_stack.text = "x %d" % count

	if item is ConsumableData:
		_slot.text = "CONSUM."
		_heal.text = "+%d" % item.heal_hp
	elif item is EquipmentData:
		_slot.text = _short_name(EquipmentData.Slot.find_key(item.slot))
		_hp.text = "+%d" % item.hp_bonus
		_atk.text = "+%d" % item.atk_bonus
		_mag.text = "+%d" % item.mag_bonus
		_dex.text = "+%d" % item.dex_bonus


func _short_name(slot_name: String) -> String:
	slot_name = slot_name.to_upper()
	return slot_name if len(slot_name) < 7 else "%s." % slot_name.substr(0, 5)
