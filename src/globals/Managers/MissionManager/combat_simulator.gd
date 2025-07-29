extends Node


static func simulate(
	party: Array[AdventurerData], mission: MissionData
) -> Dictionary[String, Variant]:
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
		party_hp += _get_health(adv)
		party_dmg += _get_attack(adv)
	var enemy_dmg := 0
	var enemy_hp := 0
	for spawn in mission.enemy_spawns:
		var enemy := spawn.enemy_data
		enemy_hp += _get_health(enemy) * spawn.count
		enemy_dmg += _get_attack(enemy) * spawn.count

	# Stat check flags
	var beat_enemies := party_dmg >= enemy_hp
	var survive_damage := party_hp > enemy_dmg

	# Final state flags
	var full_success := beat_enemies and survive_damage
	var total_failure := not beat_enemies and not survive_damage
	var partial_success := (beat_enemies or survive_damage) and not full_success

	# check for kills
	if total_failure:
		killed.append_array(party)
	else:
		if partial_success:
			# kill minimum 2 members of the team
			var to_kill: int = max(2, floor(party.size() / 2.0))
			to_kill = min(to_kill, party.size())

			# Sort party by lowest HP
			var sorted_party := party.duplicate()
			sorted_party.sort_custom(func(a, b): return a.base_stats.hp < b.base_stats.hp)

			# kill weakest members
			for i in to_kill:
				killed.append(sorted_party[i])

			# If everyone died in partial success, it's actually total failure
			if killed.size() >= party.size():
				total_failure = true
				partial_success = false
				full_success = false

	# generate loot, exp
	if not total_failure:
		var reward_scale := 1.0 if full_success else 0.5
		for spawn in mission.enemy_spawns:
			var enemy = spawn.enemy_data
			xp += enemy.xp_reward * spawn.count

			# cut drops in half if failure
			var rolls: int = floor(spawn.count * reward_scale)
			for i in rolls:
				rewards.append_array(_roll_enemy_drops(enemy))

	return {
		"success": full_success or partial_success, "killed": killed, "rewards": rewards, "xp": xp
	}


static func _get_health(chara: CharacterData) -> int:
	# get base
	var hp := chara.base_stats.hp

	if chara is AdventurerData:
		for eq in chara.equipment.values():
			var item := ItemDB.get_by_id(eq)
			if item:
				hp += item.hp

	return hp


static func _get_attack(chara: CharacterData) -> int:
	# get sum total of each stat
	var atk := chara.base_stats.atk
	var dex := chara.base_stats.dex
	var mag := chara.base_stats.mag

	if chara is AdventurerData:
		for eq in chara.equipment.values():
			var item := ItemDB.get_by_id(eq)
			if item:
				atk += item.atk
				dex += item.dex
				mag += item.dex

	# weight by class
	# TODO: in future, allow enemies to have classes too
	if chara is AdventurerData:
		match chara.class_:
			AdventurerData.Class.Warrior:
				# warriors hit hardest with ATK, but get some benefit from DEX / MAG
				return int(atk * 0.75 + dex * 0.15 + mag * 0.10)

			AdventurerData.Class.Rogue:
				# rogues favour DEX
				return int(dex * 0.75 + mag * 0.15 + atk * 0.10)

			AdventurerData.Class.Mage:
				# mages favour MAG
				return int(mag * 0.75 + dex * 0.15 + atk * 0.10)

			_:
				return atk
	else:
		return RNG.choose([atk, dex, mag])


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
