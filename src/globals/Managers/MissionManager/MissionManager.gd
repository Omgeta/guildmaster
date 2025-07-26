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
		. filter(func(st): st.status == MissionState.Status.AVAILABLE)
		. map(func(st): MissionDB.get_by_id(st.mission_id))
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

	# unlock next tower level
	if success:
		_unlock_next_tower(id)

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

	for adv_id in st.pending_killed:
		AdventurerManager.remove(adv_id)
	if st.pending_killed.size() > 0:
		NotificationService.toast(
			"Deaths", "%s died..." % _ids_to_names(st.pending_killed), Color.CRIMSON
		)
	st.pending_killed.clear()

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
	st.pending_xp = 0

	if st.pending_gold:
		SaveManager.earn_gold(st.pending_gold)
		NotificationService.toast(
			"Gold", "You earned a reward of %d gold" % st.pending_gold, Color.YELLOW
		)
	st.pending_gold = 0

	st.status = MissionState.Status.AVAILABLE
	mission_claimed.emit(id)
	SaveManager.save_sync()


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
