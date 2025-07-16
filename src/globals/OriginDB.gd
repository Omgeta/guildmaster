## Only for prefab Origins
extends Node

const ORIGINS_PATH = "res://src/core/origins/prefabs"

var _map: Dictionary[String, OriginData] = {}


func _ready():
	for fname in DirAccess.get_files_at(ORIGINS_PATH):
		if fname.ends_with(".tres"):
			var res: OriginData = load(ORIGINS_PATH + "/" + fname)
			_map[res.id] = res
	print("OriginDB: loaded %d origins" % _map.size())


func get_by_id(id: String) -> OriginData:
	return _map.get(id)


func all() -> Array[OriginData]:
	return _map.values()
