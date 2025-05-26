# PlayerData.gd
extends Resource
class_name PlayerData

@export var _currency: int = 0
@export var _origins: Array[OriginResource] = []
@export var _characters: Array[CharacterResource] = []

static func init(currency: int, origins: Array[OriginResource] , characters: Array[CharacterResource]) -> PlayerData:
	var instance = PlayerData.new()
	instance._currency = currency
	instance._origins = origins
	instance._characters = characters
	return instance
