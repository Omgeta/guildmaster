## Resource class representing a single origin's data.
class_name OriginResource extends Resource

## The display name of the origin (e.g., "Flameborn of the North").
@export var _name: String

## Alignment bias of the origin ("Chaotic", "Orderly", or "Neutral").
@export var _alignment: String

## The base rank representing rarity or strength (typically 1–5).
@export var _base_rank: int

## The frequency score indicating how common this origin is.
@export var _frequency: int

## Weighted distribution of class affinity (e.g., {"Warrior": 50, "Magician": 25, "Rogue": 25}).
@export var _class_distribution: Dictionary[String, int]


## Picks a class randomly based on the origin's class distribution.
func random_class() -> String:
	return RNG.choose_weighted_value(_class_distribution)


## Returns the alignment of this origin.
func random_alignment() -> String:
	return _alignment


## Returns the base rank of this origin.
func random_rank() -> int:
	return _base_rank


## Constructs and returns an initialized OriginResource.
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
