extends Resource
class_name GameState

enum Flag { INTRO_CUTSCENE, INTRO_GACHA }

@export var adventurers: Dictionary[String, AdventurerData] = {}
@export var origins: Array[OriginData] = []
@export var inventory: Dictionary[String, int] = {}
@export var gold: int = 1000
@export var mission_states: Dictionary[String, MissionState] = {}
@export var flags: Dictionary[Flag, bool] = {}
@export var rng_seed: int = 0


func _init():
	# default all flags to false
	for f in Flag.values():
		flags[f] = false
