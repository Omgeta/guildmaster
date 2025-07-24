extends TextureRect

const DEFAULT_STATE = "00 : 00 : 00"
const FINISHED_STATE = "DONE"

@onready var _label: Label = $Label


func reset():
	_label.text = DEFAULT_STATE


func finished():
	_label.text = FINISHED_STATE


func set_time(duration: int):
	var hours := int(duration / 3600)
	var mins := int((duration / 60) % 60)
	var secs := int(duration % 60)
	_label.text = "%02d : %02d : %02d" % [hours, mins, secs]
