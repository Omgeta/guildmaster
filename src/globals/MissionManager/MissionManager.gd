extends Node

signal mission_started(id: String)
signal mission_finished(id: String)
signal mission_claimed(id: String)

const TICK_SEC := 1.0  # how often we check states
const CombatSim := preload("res://src/globals/MissionManager/combat_simulator.gd")

var _timer: Timer


func _ready():
	_timer = Timer.new()
	_timer.wait_time = TICK_SEC
	_timer.one_shot = false
	_timer.autostart = true
	_timer.timeout.connect(_poll_completed)
	add_child(_timer)


func get_state(id: String) -> MissionState:
	return SaveManager.get_mission_states(false).get(id)


func available_missions() -> Array[MissionData]:
	return (
		SaveManager
		. get_mission_states(false)
		. values()
		. filter(func(st): st.status == MissionState.Status.AVAILABLE)
		. map(func(st): MissionDB.get_by_id(st.mission_id))
	)


func start_mission(id: String, team: Array[AdventurerData]) -> bool:
	var st := get_state(id)
	var mission := MissionDB.get_by_id(id)
	if not st or st.status != MissionState.Status.AVAILABLE:
		return false
	if team.size() < 1:
		return false

	st.status = MissionState.Status.IN_PROGRESS
	st.start_time = int(Time.get_unix_time_from_system())
	st.team_guids = team.map(func(a): return a.id)

	# mark adventurers unavailable
	for a in team:
		a.in_mission = true
		SaveManager.set_adventurer(a)

	mission_started.emit(id)
	SaveManager.save_async()

	return true


func _poll_completed() -> void:
	var now := Time.get_unix_time_from_system()
	for id in SaveManager.get_mission_states():
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
		var adv = SaveManager.find_adventurer(guid, false)
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

	SaveManager.save_async()
	mission_finished.emit(id)


func claim_rewards(id: String) -> void:
	var st = get_state(id)
	if st.status not in [MissionState.Status.SUCCESS, MissionState.Status.FAILED]:
		return  # nothing to claim

	for reward in st.pending_rewards:
		SaveManager.add_item(reward)
		# push notifcation
	st.pending_rewards.clear()

	for adv_id in st.pending_killed:
		SaveManager.remove_adventurer(adv_id)
		# push notifcation
	st.pending_killed.clear()

	for adv in st.team_guids:
		if adv not in st.pending_killed:
			pass
			# TODO: adv.reward_exp(st.pending_xp)
	st.team_guids.clear()
	st.pending_xp = 0

	st.status = MissionState.Status.AVAILABLE

	SaveManager.save_async()
	mission_claimed.emit(id)


func _unlock_next_tower(prev_id: String):
	for id in SaveManager.get_mission_states(false):
		var st := get_state(id)
		var mission := MissionDB.get_by_id(id)
		if mission.prerequisite_id == prev_id and st.status == MissionState.Status.LOCKED:
			st.status = MissionState.Status.AVAILABLE
