extends Control

signal cutscene_finished

@export var typing_speed: float = 0.05

@onready var label: Label = $CenterContainer/VBoxContainer/Text
@onready var image_node: TextureRect = $CenterContainer/VBoxContainer/Image
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var _index := 0
var _char_index := 0
var _current_text := ""
var _awaiting_continue := false
var entries: Array[Dictionary] = []


# Called manually after instantiating
func init(entries_array: Array[Dictionary]):
	entries.assign(entries_array)
	return self


func _ready() -> void:
	label.text = ""
	if entries.is_empty():
		cutscene_finished.emit()
	else:
		play_entry(entries[_index])


func play_entry(entry: Dictionary) -> void:
	_char_index = 0
	_current_text = entry.get("text", "")
	label.text = ""

	# Load optional image
	if entry.has("image") and entry["image"] != "":
		var image_tex := load(entry["image"])
		if image_tex:
			image_node.texture = image_tex
			image_node.visible = true
	else:
		image_node.visible = false

	# Load optional sound
	if entry.has("sound") and entry["sound"] != "":
		var sound := load(entry["sound"])
		if sound:
			audio_player.stream = sound
			audio_player.play()

	type_next_character()


func type_next_character() -> void:
	if _char_index < _current_text.length():
		label.text += _current_text[_char_index]
		_char_index += 1
		await get_tree().create_timer(typing_speed).timeout
		type_next_character()
	else:
		_awaiting_continue = true  # Set flag so _input() knows to listen


func _input(event: InputEvent) -> void:
	if _awaiting_continue and event.is_pressed() and not event.is_echo():
		_awaiting_continue = false
		next_entry()


func next_entry() -> void:
	_index += 1
	if _index < entries.size():
		play_entry(entries[_index])
	else:
		cutscene_finished.emit()
