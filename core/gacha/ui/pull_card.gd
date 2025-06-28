extends Control

@onready var name_label = $NameLabel
@onready var origin_label = $OriginLabel
@onready var class_label = $ClassLabel
@onready var sprite_container = $SpriteContainer


func populate(character: CharacterResource) -> void:
	await ready
	name_label.text = character._name
	origin_label.text = character._origin._name
	class_label.text = character._class

	var sprite = preload("res://core/characters/character.tscn").instantiate()
	sprite.set_character_data(character)
	sprite.scale = Vector2(3, 3)
	sprite_container.add_child(sprite)
	sprite.position = (sprite_container.size / 2.8)
