extends Control

const LOBBY_TRACK := preload("res://src/menus/assets/music/bgm/lobby.mp3")


func _ready() -> void:
	SoundService.play_bgm(LOBBY_TRACK)


func _on_gacha_button_pressed() -> void:
	SceneService.change_to(load("res://src/menus/gacha/gacha.tscn"))


func _on_mission_button_pressed() -> void:
	SceneService.change_to(load("res://src/menus/mission/mission.tscn"))


func _on_gallery_button_pressed() -> void:
	SceneService.change_to(load("res://src/menus/gallery/gallery.tscn"))
