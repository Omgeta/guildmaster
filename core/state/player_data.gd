## PlayerData.gd
class_name PlayerData extends Resource

## Total in-game currency owned by the player.
@export var _currency: int = 0

## List of OriginResource instances available to the player.
@export var _origins: Array[OriginResource] = []

## List of CharacterResource instances owned by the player.
@export var _characters: Array[CharacterResource] = []


## Static constructor for creating a new PlayerData resource.
static func init(
	currency: int, origins: Array[OriginResource], characters: Array[CharacterResource]
) -> PlayerData:
	var instance = PlayerData.new()
	instance._currency = currency
	instance._origins = origins
	instance._characters = characters
	return instance
