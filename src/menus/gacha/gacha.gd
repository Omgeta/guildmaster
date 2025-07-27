extends Control

const CHARACTER_SCN := preload("res://src/core/entities/character_3d.tscn")
const LOBBY_PCK := preload("res://src/menus/lobby/lobby.tscn")
const GACHA_TRACK := preload("res://src/menus/assets/music/bgm/gacha.mp3")
const GACHA_PULL_SFX := preload("res://src/menus/assets/music/sfx/gacha_pull.mp3")
const FADE_TIME := 0.20

@export var pop_time := 0.5
@export var show_time := 2.0

@onready var _main := $MainContainer
@onready var _viewer := $MainContainer/BannerViewer
@onready var _pull := $MainContainer/PullButtons
@onready var _currency := $MainContainer/CurrencyContainer
@onready var _stage := $SubViewportContainer/SubViewport/GachaStage
@onready var _btn_back := $MainContainer/ButtonHome
@onready var _display := $PullDisplay
@onready var _cur_banner: BannerData = _viewer.banners[0]

var _busy: bool = false


func _ready() -> void:
	# setup banners
	_viewer.banner_changed.connect(_on_banner_changed)
	_pull.pull_requested.connect(_on_pull)
	_on_banner_changed(0, _cur_banner)
	_btn_back.pressed.connect(_return_to_lobby)

	# music
	SoundService.play_bgm(GACHA_TRACK)

	# keep currencycounter updated
	SaveManager.gold_changed.connect(func(_old, _new): _refresh_afford())

	# handle intro
	if not SaveManager.get_flag(GameState.Flag.INTRO_GACHA):
		var beginner_banner = load("res://src/menus/gacha/prefabs/beginner/beginner.tres")
		await _on_pull(5, beginner_banner)
		(
			NotificationService
			. popup(
				"Gacha",
				"Gacha is a mechanic allowing you to summon new adventurers to help you from various origins.\n\nSome origins have higher chances of rare adventurers than others, but fret not, great adventurers come from all different origins\n\nNote: More expensive gacha banners tend to have higher chance of giving you new recruits! You can earn gold through missions...",
				Color.PURPLE
			)
		)
		SaveManager.set_flag(GameState.Flag.GACHA_TUTORIAL, true)


func _input(event: InputEvent) -> void:
	if _busy:
		return
	if event.is_action_pressed("ui_cancel"):
		_return_to_lobby()
	elif event.is_action_pressed("ui_left"):
		_viewer.show_prev()
	elif event.is_action_pressed("ui_right"):
		_viewer.show_next()


func _on_left_arrow_pressed() -> void:
	_viewer.show_prev()


func _on_right_arrow_pressed() -> void:
	_viewer.show_next()


func _fade_ui(to_alpha: float) -> void:
	var t := create_tween()
	t.tween_property(_main, "modulate:a", to_alpha, FADE_TIME)
	_btn_back.disabled = true
	_pull.set_enabled(false, false)
	await t.finished


func _reactivate_ui():
	_btn_back.disabled = false
	_pull.set_enabled(true, true)


func _return_to_lobby() -> void:
	SceneService.change_to(LOBBY_PCK)


func _on_banner_changed(_idx: int, banner: BannerData = null) -> void:
	_cur_banner = banner
	_pull.set_costs(_cur_banner.pull_cost, _cur_banner.pull_cost * 10)
	_refresh_afford()


func _refresh_afford() -> void:
	var gold := SaveManager.get_gold()
	_currency.set_label(str(gold))
	_pull.set_enabled(gold >= _cur_banner.pull_cost, gold >= _cur_banner.pull_cost * 10)


func _on_pull(count: int, banner: BannerData = _cur_banner) -> void:
	if _busy:
		return

	# run banner specific logic from attached script on tres
	var results: Array[AdventurerData] = banner.pull_logic.new().pull(banner, count)
	if results.is_empty():
		return

	_refresh_afford()

	_busy = true
	await _fade_ui(0.0)

	# play reveal inside the gacha cave level for each of the pulls
	for r in results:
		SoundService.play_sfx(GACHA_PULL_SFX)
		await _stage.play_reveal(r, CHARACTER_SCN, pop_time, show_time)
		await _show_display(r, pop_time, show_time)

	await _fade_ui(1.0)
	_reactivate_ui()
	_busy = false


func _show_display(r: AdventurerData, pop: float, show_: float):
	_display.set_adventurer_data(r)
	_display.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(_display, "modulate:a", 1.0, pop)
	t.tween_interval(show_)
	t.tween_property(_display, "modulate:a", 0.0, pop)
	await t.finished
