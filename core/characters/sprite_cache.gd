extends Node

const SPRITE_PATH := "res://core/characters/assets/sprites/"
const ACCESSORY := "accessory"
const BODY := "body"
const HAIR := "hair"
const OUTFIT := "outfit"
static var MAP: Dictionary[String, Dictionary] = {
	ACCESSORY: {}, BODY: {}, HAIR: {}, OUTFIT: {}
}

static func get_canonical_name(basename: String) -> String:
	return "_".join(basename.rsplit("_").slice(-2, -1))

func _ready() -> void:
	for cat in MAP:
		var dir_path := SPRITE_PATH + cat
		var dir := DirAccess.open(dir_path)
		if dir:
			dir.list_dir_begin()
			var file := dir.get_next()
			while file != "":
				if file.ends_with(".png") and not dir.current_is_dir():
					var id = get_canonical_name(file.get_basename())
					var fullpath = "%s/%s" % [dir_path, file]
					MAP[cat][id] = load(fullpath)
				file = dir.get_next()
			dir.list_dir_end()
			
func get_texture(category: String, id: String) -> Texture:
	return MAP.get(category, {}).get(id)
	
func random_sprite(category: String) -> String:
	return MAP.get(category, {}).keys().pick_random()
