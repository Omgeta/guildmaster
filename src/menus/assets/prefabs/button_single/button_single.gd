extends TextureButton

@onready var _label: Label = $Label

@export var label: String


func _ready() -> void:
	_label.text = label


func set_label(label: String):
	_label.text = label


func set_disabled_(value: bool):
	disabled = value
	modulate = Color(0.5, 0.5, 0.5, 0.7) if value else Color(1, 1, 1, 1)
	mouse_filter = Control.MOUSE_FILTER_IGNORE if value else Control.MOUSE_FILTER_STOP


func _on_down():
	modulate = Color(0.7, 0.7, 0.7)
	_label.modulate = Color(0.7, 0.7, 0.7)


func _on_up():
	modulate = Color.WHITE
	_label.modulate = Color.WHITE
