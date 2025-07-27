extends Control

signal cutscene_finished

const FAST_MULT := 0.20  # factor to speed up by

@export_range(0.005, 0.2, 0.005) var typing_speed := 0.04
@export var speed_input := "ui_accept"
@export var next_input := "ui_accept"
@export var skip_input := "ui_end"
@export var cutscene: CutsceneData

@onready var text_label: Label = $CenterContainer/VBoxContainer/Text
@onready var image_label: TextureRect = $CenterContainer/VBoxContainer/Image
@onready var timer: Timer = $Timer
@onready var tween: Tween = create_tween()
@onready var skip: TextureButton = $SkipButton

var _idx: int = 0  # track current entry
var _char_idx: int = 0  # track current char
var _skipping: bool = false
var _awaiting: bool = false  # waiting for player advancing


func _ready() -> void:
	if not cutscene:
		push_error("CutscenePlayer: no cutscene resource set")
		cutscene_finished.emit()
		return

	# start background music if provided
	if cutscene.background_music:
		SoundService.play_bgm(cutscene.background_music)
	else:
		SoundService.stop_bgm()

	_play_entry(cutscene.entries[_idx])


func _input(event: InputEvent) -> void:
	# tap to advance to next line when we are already at the end of a line
	if _awaiting and event.is_action_pressed(next_input) and not event.is_echo():
		_awaiting = false
		_next_entry()
	if event.is_action_pressed(skip_input):
		_on_skip_button_pressed()


func _process(_delta: float) -> void:
	# hook onto skip_input action for speed up in queue_next_char()
	_skipping = Input.is_action_pressed(speed_input)


func _current() -> CutsceneEntry:
	return cutscene.entries[_idx]


func _play_entry(e: CutsceneEntry) -> void:
	# reset visuals and init at start of line
	text_label.text = ""
	_char_idx = 0
	tween.kill()

	_set_image(e.image)
	SoundService.play_sfx(e.sound)

	# start typing
	_queue_next_char()


func _queue_next_char():
	var txt := _current().text
	if _char_idx < txt.length():
		text_label.text += txt.substr(_char_idx, 1)
		_char_idx += 1

		# use fast speed only while the key is held
		var speed := typing_speed * FAST_MULT if _skipping else typing_speed
		timer.start(speed)
	else:
		_finish_line()


func _on_timer_timeout():
	_queue_next_char()


func _skip_to_end_of_line() -> void:
	timer.stop()  # cancel pending tick
	var txt := _current().text
	_char_idx = txt.length()
	text_label.text = txt
	_finish_line()


func _finish_line():
	if _current().auto_advance:
		timer.start(_current().hold_time)
		await timer.timeout
		_next_entry()
	else:
		_awaiting = true  # wait for player press


func _next_entry():
	_idx += 1
	if _idx < cutscene.entries.size():
		_play_entry(cutscene.entries[_idx])
	else:
		skip.visible = false
		cutscene_finished.emit()


func _set_image(tex: Texture2D):
	if tex:
		image_label.visible = true
		image_label.texture = tex
		image_label.modulate.a = 0
		tween.kill()
		tween = create_tween()
		tween.tween_property(image_label, "modulate:a", 1, 0.25)
	else:
		image_label.visible = false


func _on_skip_button_pressed() -> void:
	skip.visible = false
	SoundService.stop_bgm()
	cutscene_finished.emit()
