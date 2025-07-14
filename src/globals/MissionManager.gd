extends Node

signal mission_started(id: String)
signal mission_finished(
	id: String, success: bool, rewards: Array[ItemData], killed: Array[AdventurerData]
)

const TICK_SEC := 1.0  # how often we check states

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
	if team.size() < mission.slots_required:
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

		# TODO: replace constant true with actual simulation
		var success := true
		_finish_mission(id, success)


func _finish_mission(id: String, success: bool):
	var st := get_state(id)
	var mission := MissionDB.get_by_id(id)
	st.status = MissionState.Status.SUCCESS if success else MissionState.Status.FAILED

	# release or kill adventurers depending on success
	var killed: Array[AdventurerData] = []
	for guid in st.team_guids:
		var adv := SaveManager.find_adventurer(guid, false)
		if adv:
			if success:
				adv.in_mission = false
			else:
				killed.append(adv)
				SaveManager.remove_adventurer(guid)

	# unlock next tower level
	if success and mission.type == MissionData.Type.TOWER:
		_unlock_next_tower(id)

	SaveManager.save_async()
	mission_finished.emit(id, success, [], killed)  #TODO: change rewards and kill calculation later


func _unlock_next_tower(prev_id: String):
	for id in SaveManager.get_mission_states(false):
		var st := get_state(id)
		var mission := MissionDB.get_by_id(id)
		if mission.prerequisite_id == prev_id and st.status == MissionState.Status.LOCKED:
			st.status = MissionState.Status.AVAILABLE
