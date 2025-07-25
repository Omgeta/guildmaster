extends TextureButton

const SFX := preload("res://src/menus/assets/music/sfx/click.mp3")


func _on_button_down() -> void:
	self.modulate = Color(0.7, 0.7, 0.7)


func _on_button_up() -> void:
	self.modulate = Color.WHITE


func _on_pressed() -> void:
	SoundManager.play_sfx(SFX)
