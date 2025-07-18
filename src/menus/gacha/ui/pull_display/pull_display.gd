extends Control

const MIN_ROT := -5.0
const MAX_ROT := 5.0

var color_util = preload("res://src/utils/ColorUtil.gd").new()

@onready var _title := $Title
@onready var _subtitle := $Subtitle
@onready var _bottom := $Bottom


func set_adventurer_data(c: AdventurerData) -> void:
	_title.text = c.display_name + " " + str(c.rarity) + "★"
	_subtitle.text = AdventurerData.Class.find_key(c.class_)
	_subtitle.add_theme_color_override("font_color", color_util.get_class_color(c.class_))
	_bottom.text = c.origin.display_name
	_random_rotation()


func _random_rotation():
	_title.rotation_degrees = RNG.randf_range(MIN_ROT, MAX_ROT)
	_subtitle.rotation_degrees = RNG.randf_range(MIN_ROT, MAX_ROT)
	_bottom.rotation_degrees = RNG.randf_range(MIN_ROT, MAX_ROT)
