extends Control

@export var banner_name: String
@export var texture: Texture2D:
	set(value):
		$UIPill2Mask/BannerImage.texture = value


func _ready() -> void:
	$UIPill2Mask/BannerImage.texture = texture
