extends Node

@onready var fade_layer = $FadeLayer
@onready var gui = $GUI


func fade_to_scene(scene: Node):
	var tween = create_tween()
	tween.tween_property(fade_layer, "modulate:a", 1.0, 0.5)
	await tween.finished

	if gui.get_child_count() > 0:
		gui.get_child(0).queue_free()

	gui.add_child(scene)

	tween = create_tween()
	tween.tween_property(fade_layer, "modulate:a", 0.0, 0.5)


func _on_splash_screen_scene_finished() -> void:
	var tween = create_tween()
	tween.tween_property(gui, "modulate:a", 1.0, 1.0)
	await tween.finished

	var new_game := not GameState.load_game()

	if new_game:
		var cutscene = (
			load("res://core/screens/cutscenes/cutscene_template.tscn")
			. instantiate()
			. init(
				(
					[
						{"text": "You wake up in a desolate land, with a tower in front of you."},
						{"text": "Your instincts scream at you."},
						{"text": "You must climb, or you won't be able to return to your world."},
						{"text": "Suddenly, a light appears from behind you."},
						{"text": "You turn to see the light take shape into a human..."},
						{
							"text":
							'"Welcome, Seeker," they say. "You are not the first, and you won\'t be the last."'
						},
						{"text": '"The tower grants power — but it demands something in return."'},
						{"text": "You ask, 'What must I give up?'"},
						{"text": 'The figure smiles. "Everything you’re unwilling to lose."'},
						{"text": '"But fear not. Allies await. The guild will guide you."'},
						{
							"text":
							"As they vanish, a sigil glows before you — a gateway to the first floor of the tower..."
						}
					]
					as Array[Dictionary]
				)
			)
		)
		cutscene.connect("cutscene_finished", fade_to_main_game)
		await fade_to_scene(cutscene)
	else:
		await fade_to_main_game()


func fade_to_main_game():
	var next_scene = preload("res://core/gacha/ui/gacha_screen.tscn").instantiate()
	await fade_to_scene(next_scene)
