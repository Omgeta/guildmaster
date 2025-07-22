extends Node

const MANIFEST_FILE = "res://src/manifest.cfg"
const MISSIONS_SECTION = "missions"

var _map: Dictionary[String, MissionData] = {}


## lifetime
func _ready() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(MANIFEST_FILE)
	if err != OK:
		push_error("MissionDB: Failed to load manifest - %s" % error_string(err))
		return

	if not cfg.has_section(MISSIONS_SECTION):
		push_warning("MissionDB: No [%s] section found in manifest" % MISSIONS_SECTION)
		return

	for id in cfg.get_section_keys(MISSIONS_SECTION):
		var path: String = cfg.get_value(MISSIONS_SECTION, id)
		_register_mission(path)

	print("MissionDB: loaded %d missions" % _map.size())


func _register_mission(res_path: String) -> void:
	var data: MissionData = ResourceLoader.load(res_path)
	if data == null:
		push_warning("MissionDB: %s is not a MissionData resource" % res_path)
		return
	if data.id == "":
		push_warning("MissionDB: %s is missing its id field" % res_path)
		return
	if _map.has(data.id):
		push_warning("MissionDB: duplicate id %s at %s" % [data.id, res_path])
		return

	_map[data.id] = data


## getters
func get_by_id(id: String) -> MissionData:
	return _map[id]


func has(id: String) -> bool:
	return _map.has(id)


func all() -> Array[MissionData]:
	return _map.values()
