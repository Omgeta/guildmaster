extends TextureButton

const SFX := preload("res://src/menus/assets/music/sfx/click.MP3")


func setup(_item, _c = null) -> void:
	push_error("Class %s did not override abstract setup()" % self)


func get_search_id() -> String:
	push_error("Class %s did not override abstract get_search_id()" % self)
	return ""


func _on_button_down() -> void:
	modulate = Color(0.7, 0.7, 0.7)


func _on_button_up() -> void:
	modulate = Color.WHITE


func _on_mouse_entered() -> void:
	modulate = Color(0.85, 0.85, 0.85)


func _on_pressed() -> void:
	SoundService.play_sfx(SFX)
