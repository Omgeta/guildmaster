extends "res://src/menus/gallery/ui/main_display/display_card/display_card.gd"

@onready var _char: Character3D = $SubViewportContainer/SubViewport/Character3D
@onready var _cam: Camera3D = $SubViewportContainer/SubViewport/Camera3D
@onready var _new: TextureRect = $MarginContainer/NewTexture
@onready var _lvl: Label = $MarginContainer/Level

const COLOR_UTIL := preload("res://src/utils/ColorUtil.gd")
static var _total = 1
var _idx


func _ready() -> void:
	_idx = _total
	_total += 1


func setup(adv: AdventurerData, _c = null) -> void:
	_char.set_character(adv)
	_char.position.z += _idx
	_cam.position.z += _idx
	tooltip_text = (
		"%s %d⭐\n%s\nLv. %d"
		% [adv.display_name, adv.rarity, AdventurerData.Class.find_key(adv.class_), adv.level]
	)
	self_modulate = COLOR_UTIL.new().get_rarity_color(adv.rarity)
	_new.visible = not adv.seen
	_lvl.text = "Lv%s" % str(adv.level)


func notify_seen():
	_new.visible = false


func get_search_id() -> String:
	return _char.data.display_name
