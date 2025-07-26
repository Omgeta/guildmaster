extends Node


static func simulate(
	party: Array[AdventurerData], mission: MissionData
) -> Dictionary[String, Variant]:
	var success := false
	var killed: Array[AdventurerData] = []
	var rewards: Array[String] = []
	var xp := 0

	# check for success
	# simple deterministic check: sum party ATK vs sum enemy DEF
	# TODO: hickey change this shit to actually make sense and be FAIR
	var party_power := 0
	for adv in party:
		party_power += adv.base_stats.atk + adv.base_stats.mag + adv.base_stats.dex

	var enemy_power := 0
	for spawn in mission.enemy_spawns:
		var enemy := spawn.enemy_data
		enemy_power += (enemy.base_stats.def) * spawn.count

	success = party_power >= enemy_power

	# get casualties
	# simple: if you fail, kill the first two members bcos why not
	# TODO: make this fair too
	if not success:
		var to_kill := int(party.size() / 2)
		for i in range(to_kill):
			killed.append(party[i])

	# generate loot, exp
	# TODO: modify to add bonus rewards
	for spawn in mission.enemy_spawns:
		var enemy = spawn.enemy_data
		xp += enemy.xp_reward * spawn.count
		for i in spawn.count:
			rewards.append_array(_roll_enemy_drops(enemy))

	return {"success": success, "killed": killed, "rewards": rewards, "xp": xp}


static func _roll_enemy_drops(enemy: EnemyData) -> Array[String]:
	var drops: Array[String] = []
	for item_id in enemy.drop_table:
		var chance := enemy.drop_table[item_id]
		if randf() < chance:
			if ItemDB.has(item_id):
				drops.append(item_id)
			else:
				push_warning("CombatSimulator: invalid drop %s from %s" % [item_id, enemy.id])
	return drops
