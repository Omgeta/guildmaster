extends Control

@export var texture: Texture2D:
	set(value):
		$Mask/BannerImage.texture = value


func _ready() -> void:
	$Mask/BannerImage.texture = texture
