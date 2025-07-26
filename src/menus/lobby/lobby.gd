extends Control


func _on_gacha_button_pressed() -> void:
	SceneService.change_to(load("res://src/menus/gacha/gacha.tscn"))


func _on_mission_button_pressed() -> void:
	SceneService.change_to(load("res://src/menus/mission/mission.tscn"))


func _on_gallery_button_pressed() -> void:
	SceneService.change_to(load("res://src/menus/gallery/gallery.tscn"))
