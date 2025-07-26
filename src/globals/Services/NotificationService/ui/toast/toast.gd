extends Control

@onready var _title: Label = $MarginContainer/HBoxContainer/VBoxContainer/Title
@onready var _desc: Label = $MarginContainer/HBoxContainer/VBoxContainer/Description
@onready var _icon: TextureRect = $MarginContainer/HBoxContainer/CenterContainer/TextureRect


func setup(title: String, desc: String, colour: Color, icon: Texture = null) -> void:
	_title.text = title
	_desc.text = desc
	_title.add_theme_color_override("font_color", colour)

	if icon:
		_icon.texture = icon
	else:
		_icon.visible = false
