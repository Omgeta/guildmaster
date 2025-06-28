extends Control

@onready var banner_list = $BannerSelector/BannerList
@onready var pull_panel = $PullPanel
@onready var animation_layer = $PullAnimationLayer

var selected_banner_id := "beginner"
var banner_config = preload("res://core/gacha/banner_config.gd").banners


func _ready():
	load_banners()


func load_banners():
	for banner_id in banner_config.keys():
		var banner = banner_config[banner_id]
		var card = preload("res://core/gacha/ui/banner_card.tscn").instantiate()
		card.setup(banner_id, banner)
		banner_list.add_child(card)
		card.pressed.connect(func(): selected_banner_id = banner_id)


func _do_pull(count: int) -> Array:
	var pull_logic = banner_config[selected_banner_id]["logic"].new()
	return pull_logic.pull(count)


func _on_single_pull_button_pressed() -> void:
	var pull_result = _do_pull(1)
	animation_layer.show_results(pull_result)


func _on_multi_pull_button_pressed() -> void:
	var pull_result = _do_pull(10)
	animation_layer.show_results(pull_result)
