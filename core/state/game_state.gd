extends Node
## Autoload for central game state

## The current player's data, including currency, characters, and origins.
var player_data: PlayerData = null

## Path to save/load the player's persistent data.
const SAVE_PATH := "user://player_data.tres"

## Starting currency for new players.
const BASE_CURRENCY := 1000

## Range for generating random origin count for new players.
const ORIGIN_LOWER := 15
const ORIGIN_UPPER := 20


## Loads player data from disk if it exists.
## Otherwise, initializes a new player with random origins and default currency.
func load_game() -> bool:
	if FileAccess.file_exists(SAVE_PATH):
		player_data = ResourceLoader.load(SAVE_PATH)
		return false
	else:
		# First-time player setup
		var OriginFactory = preload("res://core/characters/origin_factory.gd")
		player_data = PlayerData.init(
			BASE_CURRENCY, OriginFactory.generate_origins(ORIGIN_LOWER, ORIGIN_UPPER), []
		)
		save_game()
		return false


## Saves the current player data to disk.
func save_game():
	ResourceSaver.save(player_data, SAVE_PATH)


## Adds a new character to the player's collection and saves the game.
func add_character(c: CharacterResource):
	player_data._characters.append(c)
	save_game()


## Removes a character from the player's collection, if found.
func remove_character(c: CharacterResource) -> bool:
	var index := player_data._characters.find(c)
	if index != -1:
		player_data._characters.remove_at(index)
		save_game()
		return true
	return false


## Adds currency to the player's balance.
func add_currency(amount: int) -> bool:
	if amount >= 0:
		player_data._currency += amount
		save_game()
		return true
	return false


## Spends currency from the player's balance if they have enough.
func spend_currency(amount: int) -> bool:
	if amount >= 0 and player_data._currency >= amount:
		player_data._currency -= amount
		save_game()
		return true
	return false
