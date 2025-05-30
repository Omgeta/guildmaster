extends Node

@onready var fade_layer = $FadeLayer
@onready var gui = $GUI


func fade_to_screen(path: String):
	var tween = create_tween()
	tween.tween_property(fade_layer, "modulate:a", 1.0, 0.5)
	await tween.finished

	if gui.get_child_count() > 0:
		gui.get_child(0).queue_free()
	var new_scene = load(path).instantiate()
	gui.add_child(new_scene)

	tween = create_tween()
	tween.tween_property(fade_layer, "modulate:a", 0.0, 0.5)


func _on_splash_screen_scene_finished() -> void:
	var tween = create_tween()
	tween.tween_property(gui, "modulate:a", 1.0, 1.0)
	await tween.finished
	var new_game := not GameState.load_game()
	if new_game:
		fade_to_screen("res://core/cutscenes/intro.tscn")
	else:
		fade_to_screen("res://core/screens/gacha_screen.tscn")
