extends Node

const ORIGINS_PATH = "res://src/core/missions/prefabs/"

var _map: Dictionary[String, MissionData] = {}


func _ready() -> void:
	_scan_dir(ORIGINS_PATH)
	print("MissionDB: loaded %d missions" % _map.size())


func _scan_dir(folder: String) -> void:
	var dir := DirAccess.open(folder)
	if dir == null:
		push_error("MissionDB: cannot open " + folder)
		return

	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if dir.current_is_dir():
			if fname.begins_with("."):
				fname = dir.get_next()
				continue
			_scan_dir(folder + fname + "/")
		elif fname.ends_with(".tres"):
			var path := folder + fname
			var mission: MissionData = load(path)
			if mission:
				_map[mission.id] = mission
			else:
				push_warning("MissionDB: failed to load " + path)
		fname = dir.get_next()
	dir.list_dir_end()


func get_by_id(id: String) -> MissionData:
	return _map[id]


func all() -> Array[MissionData]:
	return _map.values()
