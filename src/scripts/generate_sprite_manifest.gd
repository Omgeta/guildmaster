@tool
extends EditorScript

const SHEETS_ROOT := "res://src/entities/sprites"
const MANIFEST := SHEETS_ROOT + "/sprite_manifest.cfg"
const VALID_EXT := "png"


func _run() -> void:
	var map: Dictionary = {}
	_scan_dir(SHEETS_ROOT, map)

	var cfg := ConfigFile.new()
	for id in map:
		cfg.set_value("sheets", id, map[id])

	var err := cfg.save(MANIFEST)
	if err != OK:
		push_error("Failed to write manifest: %s" % error_string(err))
	else:
		print("Sprite manifest generated: %d entries." % map.size())


func _scan_dir(folder: String, map: Dictionary) -> void:
	var dir := DirAccess.open(folder)
	if dir == null:
		push_warning("Cannot open %s" % folder)
		return

	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		var abs := "%s/%s" % [folder, fname]
		if dir.current_is_dir():
			if fname.begins_with("."):
				fname = dir.get_next()
				continue
			_scan_dir(abs, map)
		else:
			if fname.get_extension().to_lower() == VALID_EXT:
				_register_sheet(abs, map)
		fname = dir.get_next()
	dir.list_dir_end()


func _register_sheet(abs_path: String, map: Dictionary) -> void:
	var rel := abs_path.replace(SHEETS_ROOT + "/", "")
	var cat := rel.get_slice("/", 0)  # "accessory"
	var base := rel.get_basename()  # "accessory/char_a_p1_..."
	var canon := _canonical(base)  # "gogl_v01"
	var id := "%s/%s" % [cat, canon]  # "accessory/gogl_v01"

	if map.has(id):
		push_warning("Duplicate sprite id %s, keeping first and discarding other" % id)
	else:
		map[id] = abs_path


func _canonical(fname: String) -> String:
	var parts := fname.get_basename().split("_")
	return parts[-2] + "_" + parts[-1] if parts.size() >= 2 else fname
