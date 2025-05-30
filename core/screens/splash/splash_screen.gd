extends Control

signal scene_finished

@onready var logo = $CenterContainer/VBoxContainer/Logo
@onready var prompt = $CenterContainer/VBoxContainer/Prompt

var can_press := false
var pulse_tween: Tween


func _ready():
	# Initial states
	logo.modulate.a = 0.0
	prompt.modulate.a = 0.0

	# Fade in
	var tween = create_tween()
	tween.parallel().tween_property(logo, "modulate:a", 1.0, 2.5)
	tween.parallel().tween_property(prompt, "modulate:a", 1.0, 2.5)
	await tween.finished

	# Start pulsing text
	_start_pulsing()
	can_press = true


func _start_pulsing():
	pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property(prompt, "modulate:a", 0.6, 1.2)
	pulse_tween.tween_property(prompt, "modulate:a", 1.0, 1.2)


func _input(event):
	if can_press and event.is_pressed():
		can_press = true
		pulse_tween.kill()
		prompt.modulate.a = 1.0
		scene_finished.emit()
