extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Main menu loaded")


func _on_gacha_button_pressed() -> void:
	get_tree().change_scene_to_file("res://core/gacha/GachaScreen.tscn")


func _on_missions_button_pressed() -> void:
	get_tree().change_scene_to_file("res://core/missions/MissionsScreen.tscn")


func _on_characters_button_pressed() -> void:
	get_tree().change_scene_to_file("res://core/characters/CharactersScreen.tscn")
