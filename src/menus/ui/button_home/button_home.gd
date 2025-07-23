extends TextureButton


func _on_button_down() -> void:
	self.modulate = Color(0.7, 0.7, 0.7)


func _on_button_up() -> void:
	self.modulate = Color.WHITE
