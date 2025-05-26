extends Resource
class_name CharacterResource

@export var _name: String
@export var _origin: OriginResource
@export var _alignment: String
@export var _class: String
@export var _stats: Dictionary
@export var _sprite_ids: Dictionary

static func init(name: String, origin: OriginResource, alignment: String, cclass: String, stats: Dictionary, sprite_ids: Dictionary) -> CharacterResource:
	var instance = CharacterResource.new()
	instance._name = name
	instance._origin = origin
	instance._alignment = alignment
	instance._class = cclass
	instance._stats = stats
	instance._sprite_ids = sprite_ids
	return instance
