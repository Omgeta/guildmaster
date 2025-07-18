extends Node

const MANIFEST_FILE = "res://src/manifest.cfg"
const ORIGINS_SECTION = "origins"

var _map: Dictionary[String, OriginData] = {}


## lifetime
func _ready() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(MANIFEST_FILE)
	if err != OK:
		push_error("OriginDB: Failed to load manifest - %s" % error_string(err))
		return

	if not cfg.has_section(ORIGINS_SECTION):
		push_warning("OriginDB: No [%s] section found in manifest" % ORIGINS_SECTION)
		return

	for id in cfg.get_section_keys(ORIGINS_SECTION):
		var path: String = cfg.get_value(ORIGINS_SECTION, id)
		_register_origin(path)

	print("OriginDB: loaded %d origins" % _map.size())


func _register_origin(res_path: String) -> void:
	var data: OriginData = ResourceLoader.load(res_path)
	if data == null:
		push_warning("OriginDB: %s is not a OriginData resource" % res_path)
		return
	if data.id == "":
		push_warning("OriginDB: %s is missing its id field" % res_path)
		return
	if _map.has(data.id):
		push_warning("OriginDB: duplicate id %s at %s" % [data.id, res_path])
		return

	_map[data.id] = data


## getters
func get_by_id(id: String) -> OriginData:
	return _map[id].duplicate(true)


func has(id: String) -> bool:
	return _map.has(id)


func all() -> Array[OriginData]:
	return _map.values().duplicate(true)
