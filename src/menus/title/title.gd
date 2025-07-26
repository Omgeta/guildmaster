extends Control

signal scene_loaded

const INTRO_CS_RES := preload("res://src/core/cutscenes/prefabs/intro/intro_cutscene.tres")
const TITLE_TRACK := preload("res://src/menus/assets/music/bgm/title.mp3")

const FADE_TIME := 2.5
const PULSE_TIME := 1.2

@onready var logo = $CenterContainer/VBoxContainer/Logo
@onready var prompt = $CenterContainer/VBoxContainer/Prompt

var can_press := false
var pulse_tween: Tween


func _ready():
	# initial states
	logo.modulate.a = 0.0
	prompt.modulate.a = 0.0

	# background BGM
	SoundManager.play_bgm(TITLE_TRACK)

	# fade in
	var tween = create_tween()
	tween.tween_property(logo, "modulate:a", 1.0, FADE_TIME)
	tween.tween_property(prompt, "modulate:a", 1.0, FADE_TIME * 0.7)
	await tween.finished

	# start pulsing text
	_start_pulsing()
	can_press = true


func _start_pulsing():
	pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property(prompt, "modulate:a", 0.6, PULSE_TIME)
	pulse_tween.tween_property(prompt, "modulate:a", 1.0, PULSE_TIME)


func _input(event):
	if can_press and event.is_pressed():
		can_press = false
		pulse_tween.kill()
		prompt.modulate.a = 1.0
		scene_loaded.emit()
		_load_game()


func _load_game() -> void:
	var has_save := SaveManager.load_slot()
	if not has_save or not SaveManager.get_flag(GameState.Flag.INTRO_CUTSCENE):  # new game
		_start_intro_cutscene()
	elif not SaveManager.get_flag(GameState.Flag.INTRO_GACHA):
		_go_to_gacha()
	else:
		_go_to_lobby()


func _start_intro_cutscene() -> void:
	var player = load("res://src/core/cutscenes/cutscene_player.tscn").instantiate()
	player.cutscene = INTRO_CS_RES
	player.cutscene_finished.connect(_on_intro_finished)
	SceneLoader.change_to(player)


func _on_intro_finished():
	# mark the flag so we skip next time
	SaveManager.set_flag(GameState.Flag.INTRO_CUTSCENE, true)
	SaveManager.save_async()
	_go_to_gacha()


func _go_to_gacha() -> void:
	SceneLoader.change_to(load("res://src/menus/gacha/gacha.tscn"))


func _go_to_lobby() -> void:
	SceneLoader.change_to(load("res://src/menus/lobby/lobby.tscn"))
