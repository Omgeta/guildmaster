extends Resource
class_name OriginResource

@export var _name: String
@export var _alignment: String
@export var _base_rank: int
@export var _frequency: int
@export var _class_distribution: Dictionary[String, int]


func random_class() -> String:
	return RNG.choose_weighted_value(_class_distribution)


func random_alignment() -> String:
	return _alignment


func random_rank() -> int:
	return _base_rank


static func init(
	name: String,
	alignment: String,
	class_distribution: Dictionary[String, int],
	base_rank: int,
	frequency: int
) -> OriginResource:
	var instance = OriginResource.new()
	instance._name = name
	instance._alignment = alignment
	instance._class_distribution = class_distribution
	instance._base_rank = base_rank
	instance._frequency = frequency
	return instance
