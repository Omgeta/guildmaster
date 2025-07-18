extends Control

const CHARACTER_SCN := preload("res://src/core/entities/character_3d.tscn")
const LOBBY_PCK := preload("res://src/menus/lobby/lobby.tscn")
const FADE_TIME := 0.20

@export var pop_time := 0.5
@export var show_time := 2.0

@onready var _main := $MainContainer
@onready var _viewer := $MainContainer/BannerViewer
@onready var _pull := $MainContainer/PullButtons
@onready var _currency := $MainContainer/CurrencyContainer
@onready var _stage := $SubViewportContainer/SubViewport/GachaStage
@onready var _cur_banner: BannerData = _viewer.banners[0]
@onready var _btn_back := $MainContainer/ButtonBack
@onready var _display := $PullDisplay
@onready var _results := $ResultsContainer
var _busy: bool = false


func _ready() -> void:
	_viewer.banner_changed.connect(_on_banner_changed)
	_pull.pull_requested.connect(_on_pull)
	_on_banner_changed(0, _cur_banner)
	_btn_back.pressed.connect(_return_to_lobby)

	# keep currencycounter updated
	SaveManager.gold_changed.connect(func(_old, _new): _refresh_afford())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not _busy:
		_return_to_lobby()


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
	SceneLoader.change_to(LOBBY_PCK)


func _on_banner_changed(_idx: int, banner: BannerData = null) -> void:
	_cur_banner = banner
	_pull.set_costs(_cur_banner.pull_cost, _cur_banner.pull_cost * 10)
	_refresh_afford()


func _refresh_afford() -> void:
	var gold := SaveManager.get_gold()
	_currency.set_label(str(gold))
	_pull.set_enabled(gold >= _cur_banner.pull_cost, gold >= _cur_banner.pull_cost * 10)


func _on_pull(count: int) -> void:
	if _busy:
		return

	# run banner specific logic from attached script on tres
	var results: Array[AdventurerData] = _cur_banner.pull_logic.new().pull(_cur_banner, count)
	if len(results) == 0:
		return

	_refresh_afford()

	_busy = true
	await _fade_ui(0.0)

	# play reveal inside the gacha cave level for each of the pulls
	for r in results:
		await _stage.play_reveal(r, CHARACTER_SCN, pop_time, show_time)
		await show_display(r, pop_time, show_time)

	# show summary cards
	#_results.populate(results)
	#_results.visible = true

	await _fade_ui(1.0)
	_reactivate_ui()
	_busy = false


func show_display(r: AdventurerData, pop_time: float, show_time: float):
	_display.set_adventurer_data(r)
	_display.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(_display, "modulate:a", 1.0, pop_time)
	t.tween_interval(show_time)
	t.tween_property(_display, "modulate:a", 0.0, pop_time)
	await t.finished
