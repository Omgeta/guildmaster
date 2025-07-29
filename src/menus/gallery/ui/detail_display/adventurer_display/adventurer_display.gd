extends Control

@onready var _name: Label = $VBoxContainer/Name
@onready var _origin: Label = $VBoxContainer/Origin
@onready var _bg: Panel = $VBoxContainer/MarginContainer/SpriteContainer
@onready
var _char: Character3D = $VBoxContainer/MarginContainer/SpriteContainer/SubViewportContainer/SubViewport/Character3D
@onready var _level: Label = $VBoxContainer/MarginContainer/SpriteContainer/MarginContainer/Level
@onready var _xp: Label = $VBoxContainer/MarginContainer/SpriteContainer/MarginContainer/XP
@onready var _in_mission: Label = $VBoxContainer/MarginContainer/InMission
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
	_in_mission.visible = adv.in_mission
	_level.text = "Lv. %d" % adv.level
	_xp.text = "%d XP" % adv.experience
	_class.text = AdventurerData.Class.find_key(adv.class_)
	_update_stats()

	_assign_equipment_tex(EquipmentData.Slot.Accessory, _accessory)
	_assign_equipment_tex(EquipmentData.Slot.Armor, _armor)
	_assign_equipment_tex(EquipmentData.Slot.Weapon, _weapon)

	modulate = Color.DIM_GRAY if adv.in_mission else Color.WHITE


func _update_stats() -> void:
	_hp.text = _get_total_stat_str("hp")
	_atk.text = _get_total_stat_str("atk")
	_mag.text = _get_total_stat_str("mag")
	_dex.text = _get_total_stat_str("dex")


func _get_total_stat_str(stat: String) -> String:
	var base: int = _adv.base_stats[stat]
	var total_buffs: int = 0
	for e in _adv.equipment.values():
		var item := ItemDB.get_by_id(e)
		if item:
			total_buffs += item[stat]
	if total_buffs != 0:
		return "%d (+%d)" % [base + total_buffs, total_buffs]
	else:
		return "%d" % base


func _assign_equipment_tex(slot: EquipmentData.Slot, node: TextureRect) -> void:
	var id := _adv.equipment[slot]
	if id != "":
		node.texture = (ItemDB.get_by_id(id)).icon
	else:
		node.texture = null


func _on_accessory_pressed() -> void:
	if _accessory.texture and not _adv.in_mission:
		AdventurerManager.unequip(_adv.id, EquipmentData.Slot.Accessory)
		_accessory.texture = null
		_update_stats()


func _on_armor_pressed() -> void:
	if _armor.texture and not _adv.in_mission:
		AdventurerManager.unequip(_adv.id, EquipmentData.Slot.Armor)
		_armor.texture = null
		_update_stats()


func _on_weapon_pressed() -> void:
	if _weapon.texture and not _adv.in_mission:
		AdventurerManager.unequip(_adv.id, EquipmentData.Slot.Weapon)
		_weapon.texture = null
		_update_stats()
