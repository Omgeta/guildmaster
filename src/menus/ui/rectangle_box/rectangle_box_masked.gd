extends NinePatchRect

@export var switch_time := 0.15

@onready var _image = $Mask/Image

var _tween: Tween


func change_image(tex: Texture2D, instant: bool = true):
	if _tween:
		_tween.kill()
	if not instant and switch_time > 0.0:
		_tween = create_tween()
		_tween.tween_property(_image, "modulate:a", 0.0, switch_time * 0.5)
		_tween.tween_callback(_set_image.bind(tex))
		_tween.tween_property(_image, "modulate:a", 1.0, switch_time * 0.5)
	else:
		_set_image(tex)


func _set_image(tex: Texture2D):
	_image.texture = tex
