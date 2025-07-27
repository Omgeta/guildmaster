extends Resource
class_name GameState

enum Flag {
	INTRO_CUTSCENE,
	GACHA_TUTORIAL,
	LOBBY_TUTORIAL,
	MISSION_TUTORIAL,
	GALLERY_TUTORIAL,
	FIRST_MISSION,
	FIRST_FAILURE,
	FINISHED_FLOOR_20
}

@export var adventurers: Dictionary[String, AdventurerData] = {}
@export var origins: Array[OriginData] = []
@export var inventory: Dictionary[String, int] = {"heal_potion": 3}
@export var gold: int = 1000
@export var mission_states: Dictionary[String, MissionState] = {}
@export var flags: Dictionary[Flag, bool] = {}
@export var rng_seed: int = 0


func _init():
	# default all flags to false
	for f in Flag.values():
		flags[f] = false
