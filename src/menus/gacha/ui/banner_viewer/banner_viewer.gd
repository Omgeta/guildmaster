extends Control

signal banner_changed(idx: int, data: BannerData)

@export var banners: Array[BannerData]
@export var switch_time: float = 0.15

@onready var _card := $BannerCard
@onready var _mask := _card.get_child(0)

var _idx: int = 0
var _tween: Tween


func _ready() -> void:
	assert(!banners.is_empty(), "No banners assigned!")
	_apply_banner(_idx, true)


func show_prev() -> void:
	_idx = (_idx - 1 + banners.size()) % banners.size()
	_apply_banner(_idx)


func show_next() -> void:
	_idx = (_idx + 1) % banners.size()
	_apply_banner(_idx)


func _apply_banner(idx: int, instant: bool = false) -> void:
	var data := banners[idx]

	if _tween:
		_tween.kill()
	_tween = create_tween()
	if !instant and switch_time > 0.0:
		_tween.tween_property(_mask, "modulate:a", 0.0, switch_time * 0.5)
		_tween.tween_callback(func(): _populate_card(data))
		_tween.tween_property(_mask, "modulate:a", 1.0, switch_time * 0.5)
	else:
		_populate_card(data)

	banner_changed.emit(idx, data)


func _populate_card(data: BannerData) -> void:
	_card.texture = data.image
	_card.name = data.id
