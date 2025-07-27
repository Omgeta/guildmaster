extends NinePatchRect

@onready var _title: Label = $MainContainer/VBoxContainer/Title
@onready var _slay: Label = $MainContainer/VBoxContainer/Slay/Value
@onready var _bonus: RichTextLabel = $MainContainer/VBoxContainer/Bonus/Value
@onready var _main: MarginContainer = $MainContainer


func _ready() -> void:
	_main.visible = false


func setup(mission: MissionData) -> void:
	_main.visible = true
	_title.text = mission.display_name
	_slay.text = _enemy_text(mission.enemy_spawns)
	_bonus.text = _bonus_text(
		mission.bonus_exp,
		mission.bonus_gold,
		mission.bonus_rewards,
		MissionManager.get_state(mission.id).completed
	)


func _enemy_text(enemy_spawns: Array[EnemySpawn]) -> String:
	var lines := []
	for spawn in enemy_spawns:
		var name_ = spawn.enemy_data.display_name
		var count = spawn.count
		lines.append("%s x %d" % [name_, count])
	return ", ".join(lines)


func _bonus_text(xp: int, gold: int, rewards: PackedStringArray, cleared: bool = false) -> String:
	var lines := []
	if xp > 0:
		lines.append("%d XP" % xp)
	if gold > 0:
		lines.append("%d Gold" % gold)
	for reward in rewards:
		lines.append(ItemDB.find_name(reward))

	var result := ", ".join(lines)

	if cleared:
		result = "[s]%s[/s]" % result

	return result
