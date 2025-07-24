extends "res://src/menus/ui/button_single/button_single.gd"


func set_mission(msn_name: String, state: MissionState):
	set_label(msn_name)
	match state.status:
		MissionState.Status.LOCKED:
			self_modulate = Color.DIM_GRAY
			_label.self_modulate = Color.DIM_GRAY
			set_disabled_(true)
		MissionState.Status.AVAILABLE:
			self_modulate = Color.WHITE
			_label.self_modulate = Color.GREEN_YELLOW if state.completed else Color.WHITE
			set_disabled_(false)
		MissionState.Status.IN_PROGRESS:
			self_modulate = Color.DODGER_BLUE
			_label.self_modulate = Color.WHITE
			set_disabled_(false)
		MissionState.Status.SUCCESS:
			self_modulate = Color.GREEN
			_label.self_modulate = Color.GREEN_YELLOW if state.completed else Color.WHITE
			set_disabled_(false)
		MissionState.Status.FAILED:
			self_modulate = Color.FIREBRICK
			_label.self_modulate = Color.GREEN_YELLOW if state.completed else Color.WHITE
			set_disabled_(false)
