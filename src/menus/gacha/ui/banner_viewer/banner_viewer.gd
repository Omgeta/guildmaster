extends Control

signal banner_changed(idx: int, data: BannerData)

@export var banners: Array[BannerData]
@export var switch_time: float = 0.15

@onready var _card := $BannerCard

var _idx: int = 0
var _tween: Tween


func _ready() -> void:
	assert(!banners.is_empty(), "No banners assigned!")
	_apply_banner(_idx, true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		_show_prev()
	elif event.is_action_pressed("ui_right"):
		_show_next()


func _show_prev() -> void:
	if _idx > 0:
		_idx -= 1
		_apply_banner(_idx)


func _show_next() -> void:
	if _idx < banners.size() - 1:
		_idx += 1
		_apply_banner(_idx)


func _apply_banner(idx: int, instant: bool = false) -> void:
	var data := banners[idx]

	if _tween:
		_tween.kill()
	_tween = create_tween()
	if !instant and switch_time > 0.0:
		_tween.tween_property(_card, "modulate:a", 0.0, switch_time * 0.5)
		_tween.tween_callback(func(): _populate_card(data))
		_tween.tween_property(_card, "modulate:a", 1.0, switch_time * 0.5)
	else:
		_populate_card(data)

	banner_changed.emit(idx, data)


func _populate_card(data: BannerData) -> void:
	_card.banner_name = data.display_name
	_card.texture = data.image
	_card.name = data.id
