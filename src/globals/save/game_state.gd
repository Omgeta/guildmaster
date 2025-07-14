extends Resource
class_name GameState

@export var adventurers: Dictionary[String, AdventurerData] = {}
@export var origins: Array[OriginData] = []
@export var inventory: Dictionary[String, int] = {}
@export var gold: int = 1000
@export var mission_states: Dictionary[String, MissionState] = {}
@export var flags: Dictionary = {
	"seen_intro_cutscene": false,
	"finished_intro_gacha": false,
}
@export var rng_seed: int = 0
