extends Node2D

@export var _data: CharacterResource

func apply_animated_layers(sprite_ids: Dictionary[String, String]):
	const CharacterSpriteBuilder = preload("res://core/characters/character_sprite_builder.gd")
	for cat in sprite_ids:
		var sprite_node: AnimatedSprite2D = get_node(cat.capitalize())
		CharacterSpriteBuilder.setup_animated_layer(sprite_node, SpriteCache.get_texture(cat, sprite_ids[cat]))

func set_character_data(data: CharacterResource):
	_data = data
	await ready
	apply_animated_layers(data._sprite_ids)
