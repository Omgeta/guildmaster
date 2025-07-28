extends Node

signal mission_started(id: String)
signal mission_finished(id: String)
signal mission_claimed(id: String)

const TICK_SEC := 1.0  # how often we check states
const CombatSim := preload("res://src/globals/Managers/MissionManager/combat_simulator.gd")

var _timer: Timer


func _ready():
	_timer = Timer.new()
	_timer.wait_time = TICK_SEC
	_timer.one_shot = false
	_timer.autostart = true
	_timer.timeout.connect(_poll_completed)
	add_child(_timer)


func get_state(id: String) -> MissionState:
	return SaveManager._get_mission_states(false).get(id)


func available_missions() -> Array[MissionData]:
	return (
		SaveManager
		. _get_mission_states(false)
		. values()
		. filter(func(st): return st.status == MissionState.Status.AVAILABLE)
		. map(func(st): return MissionDB.get_by_id(st.mission_id))
	)


func start_mission(id: String, team_guids: Array[String]) -> bool:
	var st := get_state(id)
	if not st or st.status != MissionState.Status.AVAILABLE:
		return false
	if team_guids.size() < 1:
		return false

	st.status = MissionState.Status.IN_PROGRESS
	st.start_time = int(Time.get_unix_time_from_system())
	st.team_guids = team_guids

	# mark adventurers unavailable
	var names := _ids_to_names(team_guids)
	for adv_id in team_guids:
		AdventurerManager.start_mission(adv_id)

	mission_started.emit(id)
	_check_first_mission(names)
	NotificationService.toast(
		"Mission Started",
		"%s started with %s" % [MissionDB.get_by_id(id).display_name, names],
		Color.GREEN
	)

	return true


func _poll_completed() -> void:
	var now := Time.get_unix_time_from_system()
	for id in SaveManager._get_mission_states():
		var st: MissionState = get_state(id)
		if st.status != MissionState.Status.IN_PROGRESS:
			continue

		var mission := MissionDB.get_by_id(id)
		if now - st.start_time < mission.duration_sec:  # still running
			continue

		_finish_mission(id)


func _finish_mission(id: String):
	var st := get_state(id)
	var mission := MissionDB.get_by_id(id)

	# fetch the Adventurers for a simulation
	var party: Array[AdventurerData] = []
	for guid in st.team_guids:
		var adv = AdventurerManager.find(guid)
		if adv:
			party.append(adv)

	# run the sim and collect results
	var sim := CombatSim.simulate(party, mission)
	var success: bool = sim.success
	st.pending_killed = sim.killed.map(func(a: AdventurerData): return a.id)
	st.pending_rewards = sim.rewards
	st.pending_xp = sim.xp

	# update state
	st.status = MissionState.Status.SUCCESS if success else MissionState.Status.FAILED

	SaveManager.set_dirty()
	NotificationService.toast(
		"Mission Finished", "%s ended and ready to be claimed!" % mission.display_name, Color.GREEN
	)
	mission_finished.emit(id)


func claim_rewards(id: String) -> void:
	var st := get_state(id)
	var mission := MissionDB.get_by_id(id)
	if st.status not in [MissionState.Status.SUCCESS, MissionState.Status.FAILED]:
		return  # nothing to claim

	if not st.completed:
		st.completed = true
		st.pending_rewards.append_array(mission.bonus_rewards)
		st.pending_xp += mission.bonus_exp
		st.pending_gold += mission.bonus_gold

	for reward in st.pending_rewards:
		SaveManager.add_item(reward)
	if st.pending_rewards.size() > 0:
		NotificationService.toast("Item Drops", _ids_to_names(st.pending_rewards), Color.DARK_BLUE)
	st.pending_rewards.clear()

	var killed_s: String = _ids_to_names(st.pending_killed)
	for adv_id in st.pending_killed:
		AdventurerManager.remove(adv_id)
	if st.pending_killed.size() > 0:
		NotificationService.toast("Deaths", "%s died..." % killed_s, Color.CRIMSON)

	var survived: Array[String] = []
	for adv_id in st.team_guids:
		if adv_id not in st.pending_killed:
			survived.append(adv_id)
			AdventurerManager.reward_exp(adv_id, st.pending_xp)
		AdventurerManager.release_mission(adv_id)
	if survived:
		NotificationService.toast(
			"Experience",
			"%s gained %d experience!" % [_ids_to_names(survived), st.pending_xp],
			Color.GREEN
		)
	st.team_guids.clear()
	st.pending_killed.clear()
	st.pending_xp = 0

	if st.pending_gold:
		SaveManager.earn_gold(st.pending_gold)
		NotificationService.toast(
			"Gold", "You earned a reward of %d gold" % st.pending_gold, Color.YELLOW
		)
	st.pending_gold = 0

	if st.status == MissionState.Status.FAILED:
		_check_first_fail(killed_s)
	elif id == "tower_20":
		_check_game_clear()

	# unlock next tower level
	if st.status == MissionState.Status.SUCCESS:
		_unlock_next_tower(id)

	st.status = MissionState.Status.AVAILABLE
	mission_claimed.emit(id)
	SaveManager.save_sync()


func _check_first_mission(names: String):
	if not SaveManager.get_flag(GameState.Flag.FIRST_MISSION):
		(
			NotificationService
			. popup(
				"Missions",
				(
					"Congratulations!\n\nYou just started your first ever mission with the party of %s.\n\nWin to gather experience and grow in strength. You also earn bonus rewards for the first clear!."
					% names
				),
				Color.GREEN
			)
		)
		SaveManager.set_flag(GameState.Flag.FIRST_MISSION, true)


func _check_first_fail(names: String):
	if not SaveManager.get_flag(GameState.Flag.FIRST_FAILURE):
		(
			NotificationService
			. popup(
				"Missions",
				(
					"Oh no, you just failed your first ever mission and lost %s.\n\nGather more strength by repeating easier missions and upgrading your adventurers.\n\nBe careful not to lose all your adventurers or you journey will come to and end!."
					% names
				),
				Color.RED
			)
		)
		SaveManager.set_flag(GameState.Flag.FIRST_FAILURE, true)


func _check_game_clear():
	if not SaveManager.get_flag(GameState.Flag.FINISHED_FLOOR_20):
		(
			NotificationService
			. popup(
				"End",
				"Congratulations!\n\nYou just finished floor 20, the last floor in the game demo.\n\nThank you for playing our game, and we hope you had a lot of fun.",
				Color.GREEN
			)
		)
		SaveManager.set_flag(GameState.Flag.FINISHED_FLOOR_20, true)


func _ids_to_items(items_ids: Array[String]) -> String:
	return ", ".join(items_ids.map(func(id): return ItemDB.find_name(id)))


func _ids_to_names(adv_ids: Array[String]) -> String:
	return ", ".join(adv_ids.map(func(id): return AdventurerManager.find_name(id)))


func _unlock_next_tower(prev_id: String):
	for id in SaveManager._get_mission_states(false):
		var st := get_state(id)
		var mission := MissionDB.get_by_id(id)
		if mission.prerequisite_id == prev_id and st.status == MissionState.Status.LOCKED:
			st.status = MissionState.Status.AVAILABLE
