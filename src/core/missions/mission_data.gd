extends Resource
class_name MissionData

enum Type { TOWER, RESOURCE }

@export var id: String  # "tower_03"
@export var display_name: String
@export var type: Type
@export var prerequisite_id: String = ""  # empty means its always open
@export_range(30, 7200, 30) var duration_sec := 600  # completion time
@export var enemy_spawns: Array[EnemySpawn] = []

## first time rewards
@export var bonus_exp: int
@export var bonus_gold: int
@export var bonus_rewards: PackedStringArray = []  # item ids
