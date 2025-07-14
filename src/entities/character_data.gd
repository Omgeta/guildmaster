extends Resource
class_name CharacterData

@export var id: String  # unique ID for saves
@export var display_name: String
@export var base_stats: CharacterStats  # stats resource
@export var character_sprites: CharacterSprites  # sprites resource
@export var tags: PackedStringArray = []  # "orderly", "undead", etc
