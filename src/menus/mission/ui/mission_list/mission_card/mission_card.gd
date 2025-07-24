extends "res://src/menus/ui/button_single/button_single.gd"

const COL_OPEN := Color.WHITE
var COL_TIME := Color.hex(0xe8c75dff)  # gold
var COL_DONE := Color.hex(0x7be07bff)  # green
var COL_FAIL := Color.hex(0xdb5b5bff)  # red
var DESAT := Color(0.35, 0.35, 0.35, 1.0)  # greyed out


func set_mission(name: String, state: MissionState):
	set_label(name)
	match state.status:
		MissionState.Status.LOCKED:
			self_modulate = DESAT
			_label.self_modulate = DESAT
			set_disabled_(true)
		MissionState.Status.AVAILABLE:
			self_modulate = Color.WHITE
			_label.self_modulate = COL_OPEN
			set_disabled_(false)
		MissionState.Status.IN_PROGRESS:
			self_modulate = Color.WHITE
			_label.self_modulate = COL_TIME
			set_disabled_(true)
		MissionState.Status.SUCCESS:
			self_modulate = Color.WHITE
			_label.self_modulate = COL_DONE
			set_disabled_(false)
		MissionState.Status.FAILED:
			self_modulate = Color.WHITE
			_label.self_modulate = COL_FAIL
			set_disabled_(false)
