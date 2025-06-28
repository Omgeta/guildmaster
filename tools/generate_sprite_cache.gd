@tool
extends EditorScript


func _run():
	var categories = {"accessory": "ACCESSORY", "body": "BODY", "hair": "HAIR", "outfit": "OUTFIT"}

	var output_lines = []
	output_lines.append("## Auto-generated sprite cache")
	output_lines.append("extends Node")
	output_lines.append("")
	output_lines.append('const ACCESSORY := "accessory"')
	output_lines.append('const BODY := "body"')
	output_lines.append('const HAIR := "hair"')
	output_lines.append('const OUTFIT := "outfit"')
	output_lines.append("")
	output_lines.append("static var MAP: Dictionary[String, Dictionary] = {")

	for cat_key in categories.keys():
		var upper_key = categories[cat_key]
		output_lines.append("\t%s: {" % upper_key)
		var dir_path = "res://core/characters/assets/sprites/%s" % cat_key
		var dir = DirAccess.open(dir_path)
		if dir:
			dir.list_dir_begin()
			var file = dir.get_next()
			while file != "":
				if file.ends_with(".png") and not dir.current_is_dir():
					var id = _get_canonical_name(file.get_basename())
					var path = "%s/%s" % [dir_path, file]
					output_lines.append('\t\t"%s": load("%s"),' % [id, path])
				file = dir.get_next()
			dir.list_dir_end()
		output_lines.append("\t},")
	output_lines.append("}")

	# Write to .gd file
	var final_text = "\n".join(output_lines)
	var file = FileAccess.open("res://core/characters/sprite_cache.gd", FileAccess.WRITE)
	file.store_string(final_text)
	file.close()
	print("sprite_cache.gd generated.")


# Matches your get_canonical_name logic
func _get_canonical_name(basename: String) -> String:
	var parts = basename.split("_")
	if parts.size() >= 2:
		return "%s_%s" % [parts[-2], parts[-1]]
	else:
		return basename  # fallback if not enough parts
