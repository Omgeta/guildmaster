extends TextureButton

@onready var _char: Character3D = $SubViewportContainer/SubViewport/Character3D
@onready var _cam: Camera3D = $SubViewportContainer/SubViewport/Camera3D

@export var selected_color: Color = Color.WEB_GRAY
@export var unselected_color: Color = Color.WHITE

const color_util := preload("res://src/utils/ColorUtil.gd")
static var _total = 1
var _idx


func _ready() -> void:
	_idx = _total
	_total += 1


func setup(adv: AdventurerData) -> void:
	_char.set_character(adv)
	_char.position.z += _idx
	_cam.position.z += _idx
	tooltip_text = (
		"%s %d*\n%s\nLv. %d"
		% [adv.display_name, adv.rarity, AdventurerData.Class.find_key(adv.class_), adv.level]
	)
	self_modulate = color_util.new().get_rarity_color(adv.rarity)


func set_selected(on: bool) -> void:
	modulate = selected_color if on else unselected_color
