@tool
extends EditorScript

func _run():
	var manifest_path = "res://src/manifest.cfg"
	var output_dir = "res://exports/"
	var config = ConfigFile.new()
	var err = config.load(manifest_path)
	if err != OK:
		push_error("Failed to load manifest.cfg")
		return

	var mission_rows = ["id,display_name,type,prerequisite_id,duration_sec,slots_required,bonus_rewards,enemy_summary"]
	var item_rows = ["id,name,description,rarity,stack_limit"]
	var consumable_rows = ["id,name,description,rarity,stack_limit,heal_hp,buffs"]
	var equipment_rows = ["id,name,description,rarity,stack_limit,slot,hp_bonus,atk_bonus,dex_bonus,mag_bonus,def_bonus"]
	var enemy_rows = ["id,display_name,xp_reward,drop_table,hp,atk,dex,mag,def,tags"]

	for section in config.get_sections():
		for key in config.get_section_keys(section):
			var path = config.get_value(section, key)
			var res = load(path)
			if not res:
				push_warning("Failed to load resource: %s" % path)
				continue

			if res is MissionData:
				var bonus_rewards = ",".join(res.bonus_rewards)
				var enemy_summary = []
				for spawn in res.enemy_spawns:
					if spawn.enemy_data:
						enemy_summary.append("%s:%d" % [spawn.enemy_data.id, spawn.count])
				var enemy_str = ", ".join(enemy_summary)
				mission_rows.append("%s,%s,%s,%s,%d,%d,%s,\"%s\"" % [
					res.id, res.display_name, str(res.type), res.prerequisite_id, res.duration_sec, res.slots_required,
					bonus_rewards, enemy_str])

			elif res is ConsumableData:
				consumable_rows.append("%s,%s,\"%s\",%d,%d,%d,\"%s\"" % [
					res.id, res.name, res.description.replace("\n", " "), res.rarity, res.stack_limit, res.heal_hp, ",".join(res.buffs)])

			elif res is EquipmentData:
				equipment_rows.append("%s,%s,\"%s\",%d,%d,%s,%d,%d,%d,%d,%d" % [
					res.id, res.name, res.description.replace("\n", " "), res.rarity, res.stack_limit, res.slot,
					res.hp_bonus, res.atk_bonus, res.dex_bonus, res.mag_bonus, res.def_bonus])

			elif res is EnemyData:
				var drop_str = ""
				for k in res.drop_table:
					drop_str += "%s:%.2f;" % [k, res.drop_table[k]]
				var tags = ",".join(res.tags.map(func(tag): return str(tag)))
				var stats = res.base_stats
				enemy_rows.append("%s,%s,%d,\"%s\",%d,%d,%d,%d,%d,\"%s\"" % [
					res.id, res.display_name, res.xp_reward, drop_str.rstrip(";"),
					stats.hp, stats.atk, stats.dex, stats.mag, stats.def, tags])

	DirAccess.make_dir_recursive_absolute(output_dir)
	_save_csv(output_dir + "missions.csv", mission_rows)
	_save_csv(output_dir + "items_general.csv", item_rows)
	_save_csv(output_dir + "items_consumable.csv", consumable_rows)
	_save_csv(output_dir + "items_equipment.csv", equipment_rows)
	_save_csv(output_dir + "enemies.csv", enemy_rows)
	print("Export complete to %s" % output_dir)

func _save_csv(path: String, rows: Array):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string("\n".join(rows))
		file.close()
	else:
		push_error("Failed to write to %s" % path)
