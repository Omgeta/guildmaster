extends Node


static func simulate(
	party: Array[AdventurerData], mission: MissionData
) -> Dictionary[String, Variant]:
	var success := false
	var killed: Array[AdventurerData] = []
	var rewards: Array[String] = []
	var xp := 0

	# check for success
	# simple deterministic check: get party ATK and HP against enemy ATK and HP
	# if we win both checks, it is our complete victory, else, we lose 1-2 members
	# if we lose both stat checks, the whole party wipes
	var party_dmg := 0
	var party_hp := 0
	for adv in party:
		party_hp += adv.base_stats.hp
		match adv.class_:
			AdventurerData.Class.Warrior:
				party_dmg += adv.base_stats.atk
			AdventurerData.Class.Rogue:
				party_dmg += adv.base_stats.dex
			AdventurerData.Class.Mage:
				party_dmg += adv.base_stats.mag

	var enemy_dmg := 0
	var enemy_hp := 0
	for spawn in mission.enemy_spawns:
		var enemy := spawn.enemy_data
		enemy_hp += enemy.base_stats.hp * spawn.count
		enemy_dmg += (
			RNG.choose([enemy.base_stats.atk, enemy.base_stats.dex, enemy.base_stats.mag])
			* spawn.count
		)

	success = party_dmg >= enemy_hp and party_hp > enemy_dmg
	var total_failure := party_dmg < enemy_hp and party_hp <= enemy_dmg

	# check for kills
	if total_failure:
		killed.append_array(party)
	else:
		# if not total failure, kill first half vanguards
		var to_kill := int(party.size() / 2)
		for i in to_kill:
			killed.append(party[i])

	# generate loot, exp
	if not total_failure:
		for spawn in mission.enemy_spawns:
			var enemy = spawn.enemy_data
			xp += enemy.xp_reward * spawn.count

			# cut drops in half if failure
			for i in spawn.count / (1 if success else 2):
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
