## Resource class representing a single character's data.
class_name CharacterResource extends Resource

## Character’s full display name (e.g., "Ayla Thorne")
@export var _name: String

## The origin this character belongs to
@export var _origin: OriginResource

## Alignment of the character (e.g., "Chaotic", "Orderly", "Neutral")
@export var _alignment: String

## Class type of the character (e.g., "Warrior", "Magician", "Rogue")
@export var _class: String

## Character stats, such as HP, ATK, DEF
@export var _stats: Dictionary

## Dictionary mapping sprite categories (e.g., "hair", "body") to sprite IDs
@export var _sprite_ids: Dictionary


## Static constructor to initialize a CharacterResource with specific parameters.
static func init(
	name: String,
	origin: OriginResource,
	alignment: String,
	cclass: String,
	stats: Dictionary,
	sprite_ids: Dictionary
) -> CharacterResource:
	var instance = CharacterResource.new()
	instance._name = name
	instance._origin = origin
	instance._alignment = alignment
	instance._class = cclass
	instance._stats = stats
	instance._sprite_ids = sprite_ids
	return instance
