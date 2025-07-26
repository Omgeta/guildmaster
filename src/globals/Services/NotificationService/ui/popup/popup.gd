extends Control

signal closed

@onready var _title: Label = $Header/Title
@onready var _body: Label = $MarginContainer/Body


func setup(title: String, body: String, colour: Color) -> void:
	_title.text = title
	_title.add_theme_color_override("font_color", colour)
	_body.text = body


func _on_button_back_pressed() -> void:
	closed.emit()
