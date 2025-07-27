extends Control

@export var switch_time: float = 0.15
@export var texture: Texture2D

@onready var _banner_img = $Mask/BannerImage

var _tween: Tween


func _ready() -> void:
	_banner_img.texture = texture


func set_image(tex: Texture2D):
	_banner_img.texture = tex


func transition_image(tex: Texture2D, instant := false):
	if _tween:
		_tween.kill()
	_tween = create_tween()
	if !instant and switch_time > 0.0:
		_tween.tween_property(_banner_img, "modulate:a", 0.0, switch_time * 0.5)
		_tween.tween_callback(set_image.bind(tex))
		_tween.tween_property(_banner_img, "modulate:a", 1.0, switch_time * 0.5)
	else:
		set_image(tex)
