extends TextureButton


func set_disabled_(value: bool):
	disabled = value
	visible = value


func _on_down():
	modulate = Color(0.7, 0.7, 0.7)


func _on_up():
	modulate = Color.WHITE


func _on_entered():
	modulate = Color(0.85, 0.85, 0.85)
