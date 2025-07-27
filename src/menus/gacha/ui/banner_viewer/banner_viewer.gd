extends Control

signal banner_changed(idx: int, data: BannerData)

@export var banners: Array[BannerData]

@onready var _card := $BannerCard

var _idx: int = 0


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
	_card.name = data.id
	_card.change_image(data.image, instant)
	banner_changed.emit(idx, data)
