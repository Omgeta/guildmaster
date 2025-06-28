extends Node


func pull(count: int) -> Array[CharacterResource]:
	var results: Array[CharacterResource] = []
	for i in count:
		results.append(_pull_one())
	return results


func _pull_one() -> CharacterResource:
	var char_fac = load("res://core/characters/character_factory.gd")
	return char_fac.from_origin(GameState.player_data._origins.pick_random())
