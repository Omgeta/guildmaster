extends Button

@onready var icon_ = $Icon
@onready var title = $Title

var banner_id := ""
var banner_data := {}


func setup(id: String, data: Dictionary):
	banner_id = id
	banner_data = data

	await ready
	title.text = data.get("name", "Unknown Banner")
	icon_.texture = load(data.get("image", "res://core/gacha/assets/banners/default.png"))
