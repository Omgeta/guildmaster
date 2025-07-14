extends TextureButton

const COL_OPEN := Color.WHITE
var COL_TIME := Color.hex(0xe8c75dff)  # gold
var COL_DONE := Color.hex(0x7be07bff)  # green
var COL_FAIL := Color.hex(0xdb5b5bff)  # red
var DESAT := Color(0.35, 0.35, 0.35, 1.0)  # greyed out

@onready var _label := $Label

@export var label: String:
	set(value):
		label = value
		if _label:
			_label.text = label


func _ready():
	_label.text = label


func set_status(s: String) -> void:
	match s:
		"locked":
			self_modulate = DESAT
			_label.self_modulate = COL_OPEN
			disabled = true
		"open":
			self_modulate = Color.WHITE
			_label.self_modulate = COL_OPEN
			disabled = false
		"time":
			self_modulate = Color.WHITE
			_label.self_modulate = COL_TIME
			disabled = true
		"done":
			self_modulate = Color.WHITE
			_label.self_modulate = COL_DONE
			disabled = false
		"fail":
			self_modulate = Color.WHITE
			_label.self_modulate = COL_FAIL
			disabled = false
