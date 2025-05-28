extends Node2D
## This node represents a 2D character instance in the game world.

## Character data resource that includes stats, class, sprite IDs, etc.
@export var _data: CharacterResource


## Applies animated sprite layers to the character based on
## provided category (e.g., "body", "hair") to sprite ID dictionary mapping.
func apply_animated_layers(sprite_ids: Dictionary[String, String]):
	const CharacterSpriteBuilder = preload("res://core/characters/character_sprite_builder.gd")

	# For each sprite category, find the corresponding node and apply its animated layer
	for cat in sprite_ids:
		# Assumes each sprite node is named using PascalCase of the category name
		var sprite_node: AnimatedSprite2D = get_node(cat.capitalize())
		CharacterSpriteBuilder.setup_animated_layer(
			sprite_node, SpriteCache.get_texture(cat, sprite_ids[cat])
		)


## Sets the character data and applies its sprite layers after the node is fully ready.
func set_character_data(data: CharacterResource):
	_data = data
	await ready  # Wait until the node is fully entered into the scene tree
	apply_animated_layers(data._sprite_ids)
