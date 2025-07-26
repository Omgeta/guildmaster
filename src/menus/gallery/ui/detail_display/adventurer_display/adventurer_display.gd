extends Control

@onready var _name: Label = $VBoxContainer/Name
@onready var _origin: Label = $VBoxContainer/Origin
@onready var _bg: Panel = $VBoxContainer/MarginContainer/SpriteContainer
@onready
var _char: Character3D = $VBoxContainer/MarginContainer/SpriteContainer/SubViewportContainer/SubViewport/Character3D
@onready var _level: Label = $VBoxContainer/MarginContainer/SpriteContainer/MarginContainer/Level
@onready var _xp: Label = $VBoxContainer/MarginContainer/SpriteContainer/MarginContainer/XP
@onready var _class: Label = $VBoxContainer/VSplitContainer/Stats/Class/Value
@onready var _hp: Label = $VBoxContainer/VSplitContainer/Stats/HP/Value
@onready var _atk: Label = $VBoxContainer/VSplitContainer/Stats/ATK/Value
@onready var _mag: Label = $VBoxContainer/VSplitContainer/Stats/MAG/Value
@onready var _dex: Label = $VBoxContainer/VSplitContainer/Stats/DEX/Value

const ColorUtil = preload("res://src/utils/ColorUtil.gd")


func populate(adv: AdventurerData):
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
