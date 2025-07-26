extends TextureButton

const SFX := preload("res://src/menus/assets/music/sfx/click.mp3")

@onready var _label: Label = $Label


func set_label(text: String):
	_label.text = text


func set_disabled_(value: bool):
	disabled = value
	modulate = Color(0.5, 0.5, 0.5, 0.7) if value else Color.WHITE
	mouse_filter = Control.MOUSE_FILTER_IGNORE if value else Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_ARROW if value else Control.CURSOR_POINTING_HAND


func _on_down():
	modulate = Color(0.7, 0.7, 0.7)
	_label.modulate = Color(0.7, 0.7, 0.7)


func _on_up():
	modulate = Color.WHITE
	_label.modulate = Color.WHITE


func _on_entered():
	modulate = Color(0.85, 0.85, 0.85)
	_label.modulate = Color(0.85, 0.85, 0.85)


func _on_pressed() -> void:
	SoundService.play_sfx(SFX)
