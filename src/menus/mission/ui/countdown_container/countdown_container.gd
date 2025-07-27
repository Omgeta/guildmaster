extends TextureRect

const DEFAULT_STATE = "00 : 00 : 00"
const FINISHED_STATE = "DONE"

@onready var _label: Label = $Label


func reset():
	_label.text = DEFAULT_STATE


func finished():
	_label.text = FINISHED_STATE


func set_time(duration: int):
	var hours: int = floor(duration / 3600.0)
	var mins: int = floor(duration / 60.0) % 60
	var secs := duration % 60
	_label.text = "%02d : %02d : %02d" % [hours, mins, secs]
