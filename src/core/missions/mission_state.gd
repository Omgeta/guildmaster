extends Resource
class_name MissionState

enum Status { LOCKED, AVAILABLE, IN_PROGRESS, SUCCESS, FAILED }

@export var mission_id: String
@export var status: Status = Status.LOCKED
@export var start_time: int = 0  # unix epoch if IN_PROGRESS
@export var team_guids: PackedStringArray  # adventurers on the mission
@export var pending_rewards: PackedStringArray = []
@export var pending_killed: PackedStringArray = []
@export var pending_xp: int = 0
