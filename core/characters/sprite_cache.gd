## Indexes and caches all available sprites
extends Node

## Path to the base folder where sprite subdirectories are located.
const SPRITE_PATH := "res://core/characters/assets/sprites/"

## Sprite categories used to organize sprite assets.
const ACCESSORY := "accessory"
const BODY := "body"
const HAIR := "hair"
const OUTFIT := "outfit"

## Main storage map that categorizes loaded textures by category and ID.
## Each category maps to a dictionary where keys are sprite IDs and values are Texture resources.
static var MAP: Dictionary[String, Dictionary] = {ACCESSORY: {}, BODY: {}, HAIR: {}, OUTFIT: {}}


## Extracts a canonical ID from a file's base name.
## Assumes naming format like "prefix_id_suffix" and slices accordingly.
static func get_canonical_name(basename: String) -> String:
	return "_".join(basename.rsplit("_").slice(-2, -1))


## Automatically called when the node enters the scene tree.
## Loads all sprite textures from categorized directories into the MAP dictionary.
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


## Retrieves the Texture for a given category and ID.
func get_texture(category: String, id: String) -> Texture:
	return MAP.get(category, {}).get(id)


## Selects a random sprite ID from a given category.
func random_sprite(category: String) -> String:
	return MAP.get(category, {}).keys().pick_random()
