extends Control

const MISSION_CARD_PCK := preload("res://src/menus/mission/ui/mission_card/mission_card.tscn")

@onready var _list: VBoxContainer = $Container/HSplitContainer/MissionList/VBoxContainer
@onready var _name := $Container/HSplitContainer/MissionPanel/VBoxContainer/Name
@onready var _count: Label = $Container/HSplitContainer/MissionPanel/VBoxContainer/Countdown
@onready var _picker: Control = $Container/HSplitContainer/MissionPanel/VBoxContainer/TeamPicker
@onready var _start_btn := $Container/HSplitContainer/MissionPanel/VBoxContainer/StartButton
@onready var _panel: Control = $Container/HSplitContainer/MissionPanel

var _selected_id: String = ""
var _timer: Timer = Timer.new()


func _ready():
	_panel.hide()
	add_child(_timer)
	_timer.wait_time = 1.0
	_timer.one_shot = false
	_timer.timeout.connect(_update_countdown)

	_build_card_list()
	# refresh whenever a mission truly starts or ends:
	MissionManager.mission_started.connect(_on_mission_started)
	MissionManager.mission_finished.connect(_on_mission_finished)

	_start_btn.pressed.connect(_on_start_button_pressed)
	_picker.team_changed.connect(_update_start_state)


func _build_card_list():
	for child in _list.get_children():
		child.queue_free()
	for mission in MissionDB.all():
		var card := MISSION_CARD_PCK.instantiate()
		_setup_card_visual(card, mission)
		card.pressed.connect(_on_card_pressed.bind(mission.id))
		_list.add_child(card)


func _setup_card_visual(card: Control, mission: MissionData):
	await card.ready
	var st := MissionManager.get_state(mission.id)
	card.label = mission.display_name
	match st.status:
		MissionState.Status.LOCKED:
			card.set_status("locked")
		MissionState.Status.AVAILABLE:
			card.set_status("open")
		MissionState.Status.IN_PROGRESS:
			card.set_status("time")
		MissionState.Status.SUCCESS:
			card.set_status("done")
		MissionState.Status.FAILED:
			card.set_status("fail")


func _on_card_pressed(id: String):
	_selected_id = id
	_panel.show()
	_refresh_panel()


func _update_start_state():
	var st = MissionManager.get_state(_selected_id)
	var mission = MissionDB.get_by_id(_selected_id)
	match st.status:
		MissionState.Status.AVAILABLE:
			_start_btn.set_label("Start")
			_start_btn.set_disabled_(_picker.get_selected_team().size() < mission.slots_required)
		MissionState.Status.IN_PROGRESS:
			_start_btn.set_label("...")
			_start_btn.set_disabled_(true)
		MissionState.Status.SUCCESS, MissionState.Status.FAILED:
			_start_btn.set_label("Clear")
			_start_btn.set_disabled_(false)
		MissionState.Status.LOCKED:
			_start_btn.set_label("Locked")
			_start_btn.set_disabled_(true)


func _refresh_panel():
	var mission := MissionDB.get_by_id(_selected_id)
	var st := MissionManager.get_state(_selected_id)

	_name.text = mission.display_name
	_picker.populate(
		SaveManager.get_roster(), st.team_guids, st.status == MissionState.Status.IN_PROGRESS
	)
	_update_start_state()

	# countdown
	if st.status == MissionState.Status.IN_PROGRESS:
		_count.visible = true
		_timer.start()  # unconditionally start the ticker
	else:
		_count.visible = false
		_timer.stop()


func _clear_selection():
	_selected_id = ""
	_panel.hide()


func _on_mission_started(id: String) -> void:
	if id == _selected_id:
		_refresh_panel()


func _on_mission_finished(
	id: String, _success: bool, _rewards: Array, _lost: Array[AdventurerData]
):
	if id == _selected_id:
		_refresh_panel()  # show result instantly if we're already on it
	_build_card_list()  # refresh icons


func _update_countdown():
	var st = MissionManager.get_state(_selected_id)
	if st.status != MissionState.Status.IN_PROGRESS:
		_timer.stop()
		_count.visible = false
		return

	var md = MissionDB.get_by_id(_selected_id)
	var remain = int(st.start_time + md.duration_sec - Time.get_unix_time_from_system())
	remain = max(remain, 0)
	var h = remain / 3600
	var m = (remain / 60) % 60
	var s = remain % 60
	_count.text = "%02d:%02d:%02d" % [h, m, s]


func _on_start_button_pressed():
	var st = MissionManager.get_state(_selected_id)
	if st.status == MissionState.Status.AVAILABLE:
		# actually start the mission
		var team = _picker.get_selected_team()
		if MissionManager.start_mission(_selected_id, team):
			_refresh_panel()
	else:
		# we show the results TODO
		_on_results_close()


func _on_results_close() -> void:
	var st = MissionManager.get_state(_selected_id)
	st.status = MissionState.Status.AVAILABLE
	SaveManager.set_dirty()

	# result picker
	_picker.populate(SaveManager.get_roster(), [], false)
	_refresh_panel()


func _on_back_button_pressed():
	SceneLoader.change_to(load("res://src/menus/lobby/lobby.tscn"))
