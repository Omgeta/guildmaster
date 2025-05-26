extends Node

var player_data: PlayerData = null
const SAVE_PATH := "user://player_data.tres"
const BASE_CURRENCY := 1000
const ORIGIN_LOWER := 15
const ORIGIN_UPPER := 20

func _ready() -> void:
	load_game()

func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		player_data = ResourceLoader.load(SAVE_PATH)
	else:
		# First-time player
		var OriginFactory = preload("res://core/characters/origin_factory.gd")
		player_data = PlayerData.init(
			BASE_CURRENCY,
			OriginFactory.generate_origins(ORIGIN_LOWER, ORIGIN_UPPER),
			[]
		)
		save_game()

func save_game():
	ResourceSaver.save(player_data, SAVE_PATH)

# Accessors for convenience
func add_character(c: CharacterResource):
	player_data._characters.append(c)
	save_game()
	
func remove_character(c: CharacterResource) -> bool:
	var index := player_data._characters.find(c)
	if index != -1:
		player_data._characters.remove_at(index)
		save_game()
		return true
	return false
	
func add_currency(amount: int) -> bool:
	if amount >= 0:
		player_data._currency += amount
		save_game()
		return true
	return false

func spend_currency(amount: int) -> bool:
	if amount >= 0 and player_data._currency >= amount:
		player_data._currency -= amount
		save_game()
		return true
	return false
