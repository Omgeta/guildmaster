@tool
extends EditorScript

const VALID_EXT := "tres"
const SPRITE_EXT := "png"
const OUT_CFG := "res://src/manifest.cfg"
const ROOTS := {
	"sprites": "res://src/core/entities/assets/sprites",  # adjust if your sprites live elsewhere
	"items": "res://src/core/items/prefabs",
	"enemies": "res://src/core/entities/enemies/prefabs",
	"missions": "res://src/core/missions/prefabs",
	"origins": "res://src/core/origins/prefabs"
}


func _run() -> void:
	var all_sections := {}
	for category in ROOTS:
		var folder = ROOTS[category]
		var map = {}
		_scan(folder, category, map)
		all_sections[category] = map
		print("%s: %d entries" % [category, map.size()])
	_write(OUT_CFG, all_sections)
	print("GenerateManifest: Manifest saved to %s" % OUT_CFG)


func _scan(path: String, category: String, out: Dictionary) -> void:
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("GenerateManifest: Cannot open %s" % path)
		return
	dir.list_dir_begin()
	var name = dir.get_next()
	while name != "":
		if name.begins_with("."):  # skip dotfiles
			name = dir.get_next()
			continue
		var abs = "%s/%s" % [path, name]
		if dir.current_is_dir():  # recursive scan
			_scan(abs, category, out)
		else:
			var ext = name.get_extension().to_lower()
			if category == "sprites" and ext == SPRITE_EXT:
				_register_sprite(path, name, out)
			elif ext == VALID_EXT:
				_register_resource(abs, out)
		name = dir.get_next()
	dir.list_dir_end()


func _register_sprite(root: String, filename: String, out: Dictionary) -> void:
	var parts = filename.get_basename().split("_")
	var canon = parts[-2] + "_" + parts[-1] if parts.size() >= 2 else filename.get_basename()
	var category = root.rsplit("/", 1)[-1]  # "outfit"
	var id = "%s/%s" % [category, canon]
	if out.has(id):
		push_warning("duplicate sprite id %s" % id)
	else:
		out[id] = (root + "/" + filename)


func _register_resource(path: String, out: Dictionary) -> void:
	var res = ResourceLoader.load(path, "", 0)
	if res == null:
		push_warning("failed to load %s" % path)
		return
	# try common ID properties
	var id = str(res.get("id"))
	if id == "":
		push_warning("no id/guid on %s" % path)
		return
	if out.has(id):
		push_warning("duplicate entry %s" % id)
	else:
		out[id] = path


func _write(cfg_path: String, sections: Dictionary) -> void:
	var cfg = ConfigFile.new()
	for sect in sections.keys():
		for key in sections[sect].keys():
			cfg.set_value(sect, key, sections[sect][key])
	var err = cfg.save(cfg_path)
	if err != OK:
		push_error("save failed: %s" % err)
