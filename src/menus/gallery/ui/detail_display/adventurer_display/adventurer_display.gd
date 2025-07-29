extends Control

@onready var _name: Label = $VBoxContainer/Name
@onready var _origin: Label = $VBoxContainer/Origin
@onready var _bg: Panel = $VBoxContainer/MarginContainer/SpriteContainer
@onready
var _char: Character3D = $VBoxContainer/MarginContainer/SpriteContainer/SubViewportContainer/SubViewport/Character3D
@onready var _level: Label = $VBoxContainer/MarginContainer/SpriteContainer/MarginContainer/Level
@onready var _xp: Label = $VBoxContainer/MarginContainer/SpriteContainer/MarginContainer/XP
@onready var _class: Label = $VBoxContainer/HSplitContainer/Stats/Class/Value
@onready var _hp: Label = $VBoxContainer/HSplitContainer/Stats/HP/Value
@onready var _atk: Label = $VBoxContainer/HSplitContainer/Stats/ATK/Value
@onready var _mag: Label = $VBoxContainer/HSplitContainer/Stats/MAG/Value
@onready var _dex: Label = $VBoxContainer/HSplitContainer/Stats/DEX/Value
@onready
var _accessory: TextureRect = $VBoxContainer/HSplitContainer/MarginContainer/VBoxContainer/Accessory/Image
@onready
var _armor: TextureRect = $VBoxContainer/HSplitContainer/MarginContainer/VBoxContainer/Armor/Image
@onready
var _weapon: TextureRect = $VBoxContainer/HSplitContainer/MarginContainer/VBoxContainer/Weapon/Image

const ColorUtil = preload("res://src/utils/ColorUtil.gd")

var _adv: AdventurerData


func populate(adv: AdventurerData):
	_adv = adv
	_name.text = adv.display_name
	_origin.text = adv.origin.display_name
	_bg.self_modulate = ColorUtil.new().get_rarity_color(adv.rarity)
	_char.set_character(adv)
	_level.text = "Lv. %d" % adv.level
	_xp.text = "%d XP" % adv.experience
	_class.text = AdventurerData.Class.find_key(adv.class_)
	_hp.text = str(adv.base_stats.hp)
	_atk.text = str(adv.base_stats.atk)
	_mag.text = str(adv.base_stats.mag)
	_dex.text = str(adv.base_stats.dex)

	_assign_equipment_tex(EquipmentData.Slot.Accessory, _accessory)
	_assign_equipment_tex(EquipmentData.Slot.Armor, _armor)
	_assign_equipment_tex(EquipmentData.Slot.Weapon, _weapon)


func _assign_equipment_tex(slot: EquipmentData.Slot, node: TextureRect) -> void:
	var id := _adv.equipment[slot]
	if id != "":
		node.texture = (ItemDB.get_by_id(id)).icon
	else:
		node.texture = null


func _on_accessory_pressed() -> void:
	if _accessory.texture:
		AdventurerManager.unequip(_adv.id, EquipmentData.Slot.Accessory)
		_accessory.texture = null


func _on_armor_pressed() -> void:
	if _armor.texture:
		AdventurerManager.unequip(_adv.id, EquipmentData.Slot.Armor)
		_armor.texture = null


func _on_weapon_pressed() -> void:
	if _weapon.texture:
		AdventurerManager.unequip(_adv.id, EquipmentData.Slot.Weapon)
		_weapon.texture = null
