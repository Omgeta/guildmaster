extends Control

@onready var _missions := $MissionList
@onready var _countdown := $CountdownContainer
@onready var _picker := $TeamPicker
@onready var _timer: Timer = $Timer
@onready var _button := $MainButton

var _selected: MissionData


func _ready():
	_countdown.reset()
	_update_buttons()

	# init with towers only
	_missions.populate_missions(MissionDB.get_by_type(MissionData.Type.TOWER))

	# refresh whenever a mission truly starts or ends:
	MissionManager.mission_started.connect(_on_mission_state_change)
	MissionManager.mission_finished.connect(_on_mission_state_change)
	MissionManager.mission_claimed.connect(_on_mission_state_change)


func _refresh_countdown():
	if not _selected:
		_countdown.reset()
		return

	var st = MissionManager.get_state(_selected.id)
	if st.status != MissionState.Status.IN_PROGRESS:
		_timer.stop()

		if st.status in [MissionState.Status.SUCCESS, MissionState.Status.FAILED]:
			_countdown.finished()
		else:
			_countdown.reset()

		return

	if _timer.is_stopped():
		_timer.start()

	var remain = int(st.start_time + _selected.duration_sec - Time.get_unix_time_from_system())
	remain = max(remain, 0)
	_countdown.set_time(remain)


func _update_buttons():
	if not _selected:
		_button.set_label("Select")
		_button.set_disabled_(true)
		return

	var st = MissionManager.get_state(_selected.id)
	match st.status:
		MissionState.Status.AVAILABLE:
			if _picker.get_party().size() < 1:
				_button.set_label("Select")
				_button.set_disabled_(true)
			else:
				_button.set_label("Start")
				_button.set_disabled_(false)
				_button.pressed.connect(_on_button_start, ConnectFlags.CONNECT_ONE_SHOT)
		MissionState.Status.IN_PROGRESS:
			_button.set_label("...")
			_button.set_disabled_(true)
		MissionState.Status.SUCCESS, MissionState.Status.FAILED:
			_button.set_label("Results")
			_button.set_disabled_(false)
			_button.pressed.connect(_on_button_results, ConnectFlags.CONNECT_ONE_SHOT)


func _on_button_start():
	if _selected:
		MissionManager.start_mission(_selected.id, _picker.get_party())


func _on_button_results():
	if _selected:
		MissionManager.claim_rewards(_selected.id)


func _on_mission_state_change(id: String) -> void:
	if _selected and _selected.id == id:
		_update_buttons()
		_refresh_countdown()
		_picker.setup(AdventurerManager.get_roster(true), MissionManager.get_state(id).team_guids)
	_missions.populate_missions(MissionDB.get_by_type(MissionData.Type.TOWER))


func _on_mission_selected(mission: MissionData) -> void:
	_selected = mission
	_refresh_countdown()
	_update_buttons()
	_picker.setup(
		AdventurerManager.get_roster(true), MissionManager.get_state(mission.id).team_guids
	)


func _on_back_button_pressed():
	SceneService.change_to(load("res://src/menus/lobby/lobby.tscn"))
